//
//  KeepAwakeSwitch.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2021/12/13.
//

import AppKit
import IOKit
import IOKit.ps
import IOKit.pwr_mgt
import Combine
import Switches
import Defines

enum ClamshellSleepOverrideCommand {
    static let statusCommand = "/usr/bin/pmset -g"
    static let disableCommand = "/usr/bin/pmset -c disablesleep 0"

    static func isSleepDisabled(output: String) -> Bool {
        output.split(whereSeparator: \.isNewline).contains { line in
            let fields = line.split(whereSeparator: \.isWhitespace)
            return fields.count >= 2 && fields[0] == "SleepDisabled" && fields[1] == "1"
        }
    }
}

struct ClamshellSleepCleanupTask {
    private static let labelPrefix = "com.jacklandrin.OnlySwitch.keepawake."
    private static let supportDirectory = "/Library/Application Support/OnlySwitch"

    let label: String
    let sentinelPath: String
    let propertyListPath: String
    let propertyListData: Data
    let installCommand: String

    init(processID: Int32, identifier: String = UUID().uuidString) throws {
        guard processID > 0,
              !identifier.isEmpty,
              identifier.unicodeScalars.allSatisfy({
                  CharacterSet.alphanumerics.contains($0) || $0 == "-"
              }) else {
            throw SwitchError.OperationFailed
        }

        let label = "\(Self.labelPrefix)\(processID).\(identifier)"
        let sentinelPath = "/tmp/\(label).signal"
        let propertyListPath = "\(Self.supportDirectory)/\(label).plist"
        let cleanupBody = [
            "/bin/echo ready > \(Self.shellQuoted(sentinelPath))",
            "while /bin/kill -0 \(processID) 2>/dev/null"
                + " && /bin/test -e \(Self.shellQuoted(sentinelPath))"
                + " && ! /usr/bin/grep -q stop \(Self.shellQuoted(sentinelPath));"
                + " do /bin/sleep 1; done",
            "while ! \(ClamshellSleepOverrideCommand.disableCommand); do /bin/sleep 1; done",
            "/bin/rm -f \(Self.shellQuoted(sentinelPath)) \(Self.shellQuoted(propertyListPath))",
            "/bin/launchctl bootout system/\(label)"
        ].joined(separator: "; ")
        let propertyList: [String: Any] = [
            "Label": label,
            "ProgramArguments": ["/bin/sh", "-c", cleanupBody],
            "RunAtLoad": true,
            "StandardOutPath": "/dev/null",
            "StandardErrorPath": "/dev/null",
            "ProcessType": "Background"
        ]
        let propertyListData = try PropertyListSerialization.data(
            fromPropertyList: propertyList,
            format: .xml,
            options: 0
        )
        let encodedPropertyList = propertyListData.base64EncodedString()
        let installSteps = [
            "/bin/mkdir -p \(Self.shellQuoted(Self.supportDirectory))",
            "/bin/echo \(encodedPropertyList)"
                + " | /usr/bin/base64 -D -o \(Self.shellQuoted(propertyListPath))",
            "/usr/sbin/chown root:wheel \(Self.shellQuoted(propertyListPath))",
            "/bin/chmod 600 \(Self.shellQuoted(propertyListPath))",
            "/usr/bin/pmset -c disablesleep 1",
            "/bin/launchctl bootstrap system \(Self.shellQuoted(propertyListPath))"
        ].joined(separator: " && ")
        let rollbackSteps = [
            ClamshellSleepOverrideCommand.disableCommand,
            "/bin/launchctl bootout system/\(label) 2>/dev/null",
            "/bin/rm -f \(Self.shellQuoted(sentinelPath)) \(Self.shellQuoted(propertyListPath))",
            "exit 1"
        ].joined(separator: "; ")

        self.label = label
        self.sentinelPath = sentinelPath
        self.propertyListPath = propertyListPath
        self.propertyListData = propertyListData
        self.installCommand = "\(installSteps) || { \(rollbackSteps); }"
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}

struct KeepAwakePowerPolicy {
    private(set) var wasUsingACPower: Bool?

    mutating func shouldStopKeepAwake(
        isUsingACPower: Bool,
        isKeepAwakeActive: Bool
    ) -> Bool {
        let shouldStop = wasUsingACPower == true
            && !isUsingACPower
            && isKeepAwakeActive
        wasUsingACPower = isUsingACPower
        return shouldStop
    }

    static func currentPowerSourceUsesAC() -> Bool? {
        guard let unmanagedSnapshot = IOPSCopyPowerSourcesInfo() else { return nil }
        let snapshot = unmanagedSnapshot.takeRetainedValue()
        guard let unmanagedSource = IOPSGetProvidingPowerSourceType(snapshot) else { return nil }
        return unmanagedSource.takeUnretainedValue() as String == kIOPSACPowerValue
    }
}

final class KeepAwakeSwitch: SwitchProvider, @unchecked Sendable {
    static let shared = KeepAwakeSwitch()
    var type: SwitchType = .keepAwake
    weak var delegate: SwitchDelegate?
    private let reasonForActivity = "Reason for activity" as CFString
    private var assertionIDs: [IOPMAssertionID] = []

    @UserDefaultValue(key: UserDefaults.Key.KeepAwakeKey, defaultValue: false)
    private var preventedSleep

    /// When on, apply macOS's system-wide `disablesleep` override on AC power.
    /// Public IOPM assertions cannot override sleep caused by closing the lid.
    @UserDefaultValue(key: UserDefaults.Key.keepAwakePreventClamshellSleep, defaultValue: false)
    private var preventClamshellSleep

    /// The clamshell setting currently reflected by the live system override.
    private var appliedPreventClamshell = false
    private var clamshellSleepCleanupTask: ClamshellSleepCleanupTask?
    private var ownsClamshellOverride = false
    private var stateChangeInProgress = false

    private let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var cancellable = Set<AnyCancellable>()

    private var afterTimeMode:Bool = Preferences
        .shared
        .autoStopKeepAwakeMode.boolValue
    private var duration:Int = Preferences
        .shared
        .autoStopKeepAwakeTime
    private var startDate:Double = Preferences
        .shared
        .autoStopKeepAwakeStartDate
    private var endDate:Double = Preferences
        .shared
        .autoStopKeepAwakeEndDate

    private var timerCounter = 0
    private var powerPolicy = KeepAwakePowerPolicy()

    private var durationBySecond:Int {
        duration * 60
    }

    init() {
        if preventedSleep {
            do {
                try createAssertions()
            } catch {
                preventedSleep = !assertionIDs.isEmpty
            }
        }

        setSettingNotification()
        setTimer()

        if preventedSleep && preventClamshellSleep {
            restoreClamshellOverrideAfterLaunch()
        }
    }

    deinit {
        cancellable.removeAll()
    }

    private func setSettingNotification() {
        NotificationCenter.default.addObserver(forName: .changeKeepAwakeSetting, object: nil, queue: .main) { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.afterTimeMode = Preferences
                .shared
                .autoStopKeepAwakeMode.boolValue
            strongSelf.duration = Preferences
                .shared
                .autoStopKeepAwakeTime
            strongSelf.startDate = Preferences
                .shared
                .autoStopKeepAwakeStartDate
            strongSelf.endDate = Preferences
                .shared
                .autoStopKeepAwakeEndDate
            if strongSelf.preventedSleep
                && strongSelf.preventClamshellSleep != strongSelf.appliedPreventClamshell {
                Task { @MainActor [weak strongSelf] in
                    await strongSelf?.applyChangedClamshellSetting()
                }
            }
        }
    }

    private func restoreClamshellOverrideAfterLaunch() {
        Task { @MainActor [weak self] in
            // A cleanup task from the previous process polls its parent once per second.
            try? await Task<Never, Never>.sleep(nanoseconds: 2_000_000_000)
            guard let self, self.preventedSleep, self.preventClamshellSleep else { return }
            do {
                try await self.enableClamshellOverride()
                self.appliedPreventClamshell = true
            } catch {
                Preferences.shared.keepAwakePreventClamshellSleep = false
                self.appliedPreventClamshell = false
            }
        }
    }

    @MainActor
    private func applyChangedClamshellSetting() async {
        guard !stateChangeInProgress else { return }
        let requestedValue = preventClamshellSleep
        let previousValue = appliedPreventClamshell
        stateChangeInProgress = true
        defer { stateChangeInProgress = false }

        do {
            if requestedValue {
                try await enableClamshellOverride()
            } else {
                try await disableClamshellOverride()
            }
            appliedPreventClamshell = requestedValue
        } catch {
            Preferences.shared.keepAwakePreventClamshellSleep = previousValue
        }
    }

    private func setTimer() {
        secondTimer.sink{ [weak self] _ in
            guard let strongSelf = self else {return}
            if let isUsingACPower = KeepAwakePowerPolicy.currentPowerSourceUsesAC(),
               strongSelf.powerPolicy.shouldStopKeepAwake(
                   isUsingACPower: isUsingACPower,
                   isKeepAwakeActive: strongSelf.preventedSleep
               ) {
                Task { @MainActor [weak strongSelf] in
                    guard let strongSelf else { return }
                    do {
                        try await strongSelf.switchOff()
                    } catch {
                        NSLog("Failed to turn off Keep Awake after disconnecting power: \(error)")
                    }
                    NotificationCenter.default.post(
                        name: .refreshSingleSwitchStatus,
                        object: strongSelf.type
                    )
                }
            }
            if strongSelf.afterTimeMode {
                strongSelf.stopAfterTime()
            } else {
                strongSelf.scheduleTask()
            }
        }.store(in: &cancellable)
    }

    private func stopAfterTime() {
        guard preventedSleep, durationBySecond != 0 else {return} //switch is on and duration isn't never
        timerCounter += 1
        if timerCounter == durationBySecond {
            timerCounter = 0
            Task { @MainActor [weak self] in
                guard let self else { return }
                try? await self.switchOff()
                NotificationCenter.default.post(name: .refreshSingleSwitchStatus, object: self.type)
            }
        }
    }

    private func scheduleTask() {
        timerCounter = 0
        let startTimeToday = Date().date(at: 0, minutes: 0).timeIntervalSince1970 + startDate
        var endTimeToday = Date().date(at: 0, minutes: 0).timeIntervalSince1970 + endDate
        if endTimeToday <= startTimeToday {
            endTimeToday += 24 * 60 * 60 //tomorrow time
        }
        let nowTimeInterval = Date().timeIntervalSince1970
        if preventedSleep {
            if endTimeToday >= nowTimeInterval - 1 && endTimeToday <= nowTimeInterval + 1 {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    try? await self.switchOff()
                    NotificationCenter.default.post(name: .refreshSingleSwitchStatus, object: self.type)
                }
            }
        } else {
            if startTimeToday >= nowTimeInterval - 1 && startTimeToday <= nowTimeInterval + 1 {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    try? await self.switchOn()
                    NotificationCenter.default.post(name: .refreshSingleSwitchStatus, object: self.type)
                }
            }
        }

    }

    @MainActor
    func currentInfo() async -> String {
        return ""
    }

    @MainActor
    func currentStatus() async -> Bool {
        return preventedSleep
    }

    @MainActor
    func operateSwitch(isOn: Bool) async throws {
        if isOn {
            try await switchOn()
        } else {
            try await switchOff()
        }
    }

    /// Keep the display awake while the switch is on. Lid-close sleep is handled
    /// separately because IOPM assertions do not override clamshell sleep.
    private func createAssertions() throws {
        guard assertionIDs.isEmpty else { return }
        var id = IOPMAssertionID()
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reasonForActivity,
            &id)
        if success == kIOReturnSuccess {
            assertionIDs.append(id)
        } else {
            throw SwitchError.OperationFailed
        }
    }

    @discardableResult
    private func releaseAllAssertions() -> Bool {
        var failedIDs: [IOPMAssertionID] = []
        for id in assertionIDs {
            if IOPMAssertionRelease(id) != kIOReturnSuccess {
                failedIDs.append(id)
            }
        }
        assertionIDs = failedIDs
        return failedIDs.isEmpty
    }

    @MainActor
    private func switchOn() async throws {
        guard !stateChangeInProgress else { throw SwitchError.OperationFailed }
        stateChangeInProgress = true
        defer { stateChangeInProgress = false }

        do {
            try createAssertions()
            if preventClamshellSleep {
                try await enableClamshellOverride()
            }
            appliedPreventClamshell = preventClamshellSleep
            preventedSleep = true
            timerCounter = 0
        } catch {
            if ownsClamshellOverride {
                try? await disableClamshellOverride()
            }
            _ = releaseAllAssertions()
            preventedSleep = !assertionIDs.isEmpty
            throw SwitchError.OperationFailed
        }
    }

    @MainActor
    private func switchOff() async throws {
        guard !stateChangeInProgress else { throw SwitchError.OperationFailed }
        stateChangeInProgress = true
        defer { stateChangeInProgress = false }

        let shouldDisableClamshell = appliedPreventClamshell || ownsClamshellOverride
        guard releaseAllAssertions() else {
            throw SwitchError.OperationFailed
        }
        preventedSleep = false
        if shouldDisableClamshell {
            try await disableClamshellOverride()
            appliedPreventClamshell = false
        }
    }

    @MainActor
    private func enableClamshellOverride() async throws {
        if try await isSystemSleepDisabled() {
            return
        }

        let task = try ClamshellSleepCleanupTask(
            processID: ProcessInfo.processInfo.processIdentifier
        )
        guard FileManager.default.createFile(atPath: task.sentinelPath, contents: Data()) else {
            throw SwitchError.OperationFailed
        }
        clamshellSleepCleanupTask = task
        var taskWasInstalled = false

        do {
            _ = try await task.installCommand.runAppleScript(isShellCMD: true, with: true)
            taskWasInstalled = true
            guard await waitForCleanupTaskReady(task),
                  try await waitForSystemSleepDisabled(expected: true) else {
                throw SwitchError.OperationFailed
            }
            ownsClamshellOverride = true
        } catch {
            if taskWasInstalled {
                try? "stop".write(
                    toFile: task.sentinelPath,
                    atomically: true,
                    encoding: .utf8
                )
                _ = await waitForCleanupTaskStopped(task)
            }
            try? FileManager.default.removeItem(atPath: task.sentinelPath)
            clamshellSleepCleanupTask = nil
            ownsClamshellOverride = false
            throw SwitchError.OperationFailed
        }
    }

    @MainActor
    private func disableClamshellOverride() async throws {
        guard ownsClamshellOverride else { return }
        guard let task = clamshellSleepCleanupTask else {
            throw SwitchError.OperationFailed
        }

        try "stop".write(
            toFile: task.sentinelPath,
            atomically: true,
            encoding: .utf8
        )
        guard await waitForCleanupTaskStopped(task),
              try await waitForSystemSleepDisabled(expected: false) else {
            throw SwitchError.OperationFailed
        }
        clamshellSleepCleanupTask = nil
        ownsClamshellOverride = false
    }

    @MainActor
    private func isSystemSleepDisabled() async throws -> Bool {
        let output = try await ClamshellSleepOverrideCommand.statusCommand
            .runAppleScript(isShellCMD: true)
        return ClamshellSleepOverrideCommand.isSleepDisabled(output: output)
    }

    @MainActor
    private func waitForSystemSleepDisabled(expected: Bool) async throws -> Bool {
        for _ in 0..<20 {
            if try await isSystemSleepDisabled() == expected {
                return true
            }
            try? await Task<Never, Never>.sleep(nanoseconds: 100_000_000)
        }
        return false
    }

    @MainActor
    private func waitForCleanupTaskReady(_ task: ClamshellSleepCleanupTask) async -> Bool {
        for _ in 0..<40 {
            if let content = try? String(contentsOfFile: task.sentinelPath, encoding: .utf8),
               content.trimmingCharacters(in: .whitespacesAndNewlines) == "ready" {
                return true
            }
            try? await Task<Never, Never>.sleep(nanoseconds: 100_000_000)
        }
        return false
    }

    @MainActor
    private func waitForCleanupTaskStopped(_ task: ClamshellSleepCleanupTask) async -> Bool {
        for _ in 0..<40 {
            if !FileManager.default.fileExists(atPath: task.sentinelPath) {
                return true
            }
            try? await Task<Never, Never>.sleep(nanoseconds: 100_000_000)
        }
        return false
    }

    func isVisible() -> Bool {
        return true
    }
}
