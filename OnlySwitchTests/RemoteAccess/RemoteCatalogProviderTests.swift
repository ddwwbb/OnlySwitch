import RemoteCore
import Switches
import XCTest
@testable import OnlySwitch

@MainActor
final class RemoteCatalogProviderTests: XCTestCase {
    func testCatalogIncludesUnavailableBuiltInsAndAllInstalledContent() async throws {
        let provider = RemoteCatalogProvider(
            builtIns: { [.darkMode, .airPods] },
            makeBuiltIn: { FakeSwitch(type: $0, visible: $0 == .darkMode) },
            shortcutNames: { ["Focus Setup", "Deploy"] }
        )

        let catalog = try await provider.catalog()

        XCTAssertEqual(catalog.count, 4)
        let airPods = catalog[id: .init(kind: .builtIn, value: "512")]
        XCTAssertEqual(airPods?.isAvailable, false)
        XCTAssertEqual(airPods?.unavailableReason, "No compatible AirPods are configured or connected")
        XCTAssertNotNil(catalog[id: .init(kind: .shortcut, value: "Focus Setup")])
        XCTAssertNotNil(catalog[id: .init(kind: .shortcut, value: "Deploy")])
    }

    func testCatalogMapsBehaviorIconsAndDestructiveFlags() async throws {
        let provider = RemoteCatalogProvider(
            builtIns: { [.topNotch, .mute, .emptyTrash, .xcodeCache] },
            makeBuiltIn: { FakeSwitch(type: $0, visible: true) },
            shortcutNames: { [] }
        )

        let catalog = try await provider.catalog()

        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "8")]?.behavior, .switch)
        XCTAssertEqual(
            catalog[id: .init(kind: .builtIn, value: "8")]?.icon,
            .systemSymbol("speaker.wave.2.circle")
        )
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "16384")]?.behavior, .button)
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "16384")]?.isDestructive, true)
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "2048")]?.isDestructive, true)
        guard case .png = catalog[id: .init(kind: .builtIn, value: "4")]?.icon else {
            return XCTFail("Top Notch must use its custom image as PNG data")
        }
    }

    func testUnavailableBuiltInsUseReasonsMatchingVisibilityPredicates() async throws {
        let types: [SwitchType] = [
            .hideMenubarIcons, .fkey,
            .smallLaunchpadIcon, .spotify, .applemusic,
        ]
        let provider = RemoteCatalogProvider(
            builtIns: { types },
            makeBuiltIn: { FakeSwitch(type: $0, visible: false) },
            shortcutNames: { [] }
        )

        let catalog = try await provider.catalog()

        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "134217728")]?.unavailableReason,
                       "Menu bar icon collapsing is disabled in OnlySwitch settings")
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "268435456")]?.unavailableReason,
                       "Function-key mode control is not supported by this keyboard")
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "524288")]?.unavailableReason,
                       "Launchpad icon sizing is not supported on macOS 26 or later")
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "16777216")]?.unavailableReason,
                       "Spotify is not running on this Mac")
        XCTAssertEqual(catalog[id: .init(kind: .builtIn, value: "33554432")]?.unavailableReason,
                       "Apple Music is not running on this Mac")
    }

    func testStatusNormalizesSecondaryInformation() async throws {
        let control = FakeSwitch(type: .darkMode, visible: true)
        control.status = true
        control.info = "  Active display  "
        let provider = RemoteCatalogProvider(
            builtIns: { [.darkMode] },
            makeBuiltIn: { _ in control },
            shortcutNames: { [] },
            now: { Date(timeIntervalSince1970: 123) }
        )

        let status = try await provider.status(.init(kind: .builtIn, value: "2"), 7)

        XCTAssertEqual(status.isOn, true)
        XCTAssertEqual(status.secondaryInformation, "Active display")
        XCTAssertEqual(status.revision, 7)
        XCTAssertEqual(status.updatedAt, Date(timeIntervalSince1970: 123))
    }
}
