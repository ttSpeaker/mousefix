import XCTest
@testable import MouseFixCore

final class AppConfigTests: XCTestCase {
    func testAppConfigSerializationRoundtrip() throws {
        var config = AppConfig()
        config.scroll.stepSize = 42.0
        config.scroll.invertDirection = false
        config.buttons[3] = ButtonMapping(button: 3, clickAction: .smartZoom, holdAction: .showDesktop)

        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        let decoded = try JSONDecoder().decode(AppConfig.self, from: data)

        XCTAssertEqual(decoded, config)
    }

    func testLaunchdPlistGeneration() {
        let plist = LaunchdService.generatePlist(executablePath: "/usr/local/bin/mousefix")
        XCTAssertTrue(plist.contains("<string>com.user.mousefix</string>"))
        XCTAssertTrue(plist.contains("<string>/usr/local/bin/mousefix</string>"))
        XCTAssertTrue(plist.contains("<key>RunAtLoad</key>"))
    }
}
