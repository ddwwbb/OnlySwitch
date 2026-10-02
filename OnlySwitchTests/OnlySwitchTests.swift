//
//  OnlySwitchTests.swift
//  OnlySwitchTests
//
//  Created by Jacklandrin on 2022/5/18.
//

import XCTest
import Combine
import Testing
@testable import OnlySwitch

class OnlySwitchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    @MainActor
    func testDimScreenSliderPublishesRoundedValue() {
        let viewModel = DimScreenSettingVM()

        viewModel.sliderValue = 0.73

        XCTAssertEqual(viewModel.sliderValue, 0.7)
        XCTAssertEqual(Preferences.shared.dimScreenPercent, 0.7)
    }

    @MainActor
    func testAppearanceNotificationSeesNewValue() {
        let originalAppearance = Preferences.shared.currentAppearance
        let newAppearance = originalAppearance == SwitchListAppearance.single.rawValue
            ? SwitchListAppearance.dual.rawValue
            : SwitchListAppearance.single.rawValue
        var observedAppearance: String?
        let observer = NotificationCenter.default.addObserver(
            forName: .shouldHidePopover,
            object: nil,
            queue: .main
        ) { _ in
            observedAppearance = Preferences.shared.currentAppearance
        }
        defer {
            NotificationCenter.default.removeObserver(observer)
            Preferences.shared.currentAppearance = originalAppearance
        }

        Preferences.shared.currentAppearance = newAppearance

        XCTAssertEqual(observedAppearance, newAppearance)
    }

    @MainActor
    func testGeneralVMPublishesAppearanceSelection() {
        let viewModel = GeneralVM()
        let originalAppearance = viewModel.currentAppearance
        let newAppearance = originalAppearance == SwitchListAppearance.single.rawValue
            ? SwitchListAppearance.dual.rawValue
            : SwitchListAppearance.single.rawValue
        var didPublishChange = false
        let cancellable = viewModel.objectWillChange.sink {
            didPublishChange = true
        }
        defer {
            viewModel.currentAppearance = originalAppearance
            cancellable.cancel()
        }

        viewModel.currentAppearance = newAppearance

        XCTAssertTrue(didPublishChange)
        XCTAssertEqual(viewModel.currentAppearance, newAppearance)
    }

    @MainActor
    func testDesktopPetIsHiddenByDefaultAndPublishesChanges() {
        let defaults = UserDefaults.standard
        let key = UserDefaults.Key.showDesktopPet
        let original = defaults.object(forKey: key)
        defer {
            if let original {
                defaults.set(original, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
        defaults.removeObject(forKey: key)

        XCTAssertFalse(Preferences.shared.showDesktopPet)

        var observed: Bool?
        let observer = NotificationCenter.default.addObserver(
            forName: .desktopPetVisibilityChanged,
            object: nil,
            queue: .main
        ) { _ in
            observed = Preferences.shared.showDesktopPet
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        Preferences.shared.showDesktopPet = true

        XCTAssertEqual(observed, true)
    }

    func testClamshellOverrideInstallsSystemCleanupTaskWithFirstAuthorization() throws {
        let task = try ClamshellSleepCleanupTask(
            processID: 1234,
            identifier: "test"
        )

        XCTAssertTrue(task.installCommand.contains("/usr/bin/pmset -c disablesleep 1"))
        XCTAssertTrue(task.installCommand.contains("/bin/launchctl bootstrap system"))
        XCTAssertTrue(task.installCommand.contains("/usr/bin/pmset -c disablesleep 0"))
        XCTAssertFalse(task.installCommand.contains("launchctl submit"))
        XCTAssertFalse(task.installCommand.contains("nohup"))

        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        let decodedPropertyList = try PropertyListSerialization.propertyList(
            from: task.propertyListData,
            options: [],
            format: &propertyListFormat
        )
        let propertyList = try XCTUnwrap(decodedPropertyList as? [String: Any])
        XCTAssertEqual(propertyList["Label"] as? String, task.label)
        XCTAssertEqual(propertyList["RunAtLoad"] as? Bool, true)
        let arguments = try XCTUnwrap(propertyList["ProgramArguments"] as? [String])
        XCTAssertEqual(Array(arguments.prefix(2)), ["/bin/sh", "-c"])
        let cleanupBody = try XCTUnwrap(arguments.last)
        XCTAssertTrue(cleanupBody.contains("/bin/kill -0 1234"))
        XCTAssertTrue(cleanupBody.contains("/usr/bin/pmset -c disablesleep 0"))
        XCTAssertTrue(cleanupBody.contains("/bin/launchctl bootout system/\(task.label)"))
        XCTAssertTrue(cleanupBody.contains(task.sentinelPath))

        let syntaxCheck = Process()
        syntaxCheck.executableURL = URL(fileURLWithPath: "/bin/sh")
        syntaxCheck.arguments = ["-n", "-c", task.installCommand]
        try syntaxCheck.run()
        syntaxCheck.waitUntilExit()
        XCTAssertEqual(syntaxCheck.terminationStatus, 0)
    }

    func testClamshellOverrideStatusParsing() {
        XCTAssertTrue(
            ClamshellSleepOverrideCommand.isSleepDisabled(
                output: "System-wide power settings:\n SleepDisabled\t\t1\n"
            )
        )
        XCTAssertFalse(
            ClamshellSleepOverrideCommand.isSleepDisabled(
                output: "System-wide power settings:\n SleepDisabled\t\t0\n"
            )
        )
        XCTAssertFalse(
            ClamshellSleepOverrideCommand.isSleepDisabled(
                output: "Currently in use:\n sleep 0\n"
            )
        )
    }

    func testKeepAwakeStopsOnlyWhenPowerChangesFromACToBattery() {
        var policy = KeepAwakePowerPolicy()

        XCTAssertFalse(
            policy.shouldStopKeepAwake(isUsingACPower: true, isKeepAwakeActive: true)
        )
        XCTAssertTrue(
            policy.shouldStopKeepAwake(isUsingACPower: false, isKeepAwakeActive: true)
        )
        XCTAssertFalse(
            policy.shouldStopKeepAwake(isUsingACPower: false, isKeepAwakeActive: true)
        )
        XCTAssertFalse(
            policy.shouldStopKeepAwake(isUsingACPower: true, isKeepAwakeActive: true)
        )
        XCTAssertFalse(
            policy.shouldStopKeepAwake(isUsingACPower: false, isKeepAwakeActive: false)
        )
    }

    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

struct KeepAwakeDisplayTests {
    @Test func closingLidReleasesDisplayKeepAwakeAndOpeningRestoresIt() {
        var state = KeepAwakeDisplayState(
            isLidClosed: false, hasExternalDisplay: false, isBuiltinDisplayAwake: true
        )
        #expect(state.shouldKeepDisplayAwake)
        #expect(!state.shouldSleepDisplay(preventClamshellSleep: true))

        state.isLidClosed = true
        #expect(!state.shouldKeepDisplayAwake)
        #expect(state.shouldSleepDisplay(preventClamshellSleep: true))

        state.isBuiltinDisplayAwake = false
        #expect(!state.shouldSleepDisplay(preventClamshellSleep: true))

        state.isBuiltinDisplayAwake = true
        #expect(state.shouldSleepDisplay(preventClamshellSleep: true))

        state.isLidClosed = false
        #expect(state.shouldKeepDisplayAwake)
        #expect(!state.shouldSleepDisplay(preventClamshellSleep: true))
    }

    @Test func clamshellModeDoesNotPutExternalDisplaysToSleep() {
        let state = KeepAwakeDisplayState(
            isLidClosed: true, hasExternalDisplay: true, isBuiltinDisplayAwake: true
        )
        #expect(state.shouldKeepDisplayAwake)
        #expect(!state.shouldSleepDisplay(preventClamshellSleep: true))
    }

    @Test func ordinaryKeepAwakeDoesNotForceClamshellDisplaySleep() {
        let state = KeepAwakeDisplayState(
            isLidClosed: true, hasExternalDisplay: false, isBuiltinDisplayAwake: true
        )
        #expect(!state.shouldSleepDisplay(preventClamshellSleep: false))
    }

    @Test func openingLidWakesSleepingDisplayButDoesNotUndoManualSleep() {
        var state = KeepAwakeDisplayState(
            isLidClosed: true, hasExternalDisplay: false, isBuiltinDisplayAwake: false
        )
        #expect(!state.shouldWakeDisplay(wasLidClosed: true))
        state.isLidClosed = false
        #expect(state.shouldWakeDisplay(wasLidClosed: true))
        #expect(!state.shouldWakeDisplay(wasLidClosed: false))
        state.isBuiltinDisplayAwake = true
        #expect(!state.shouldWakeDisplay(wasLidClosed: true))
    }
}
