import XCTest
@testable import MouseFixCore

final class ButtonStateMachineTests: XCTestCase {
    func testClickTriggersClickAction() {
        let stateMachine = ButtonStateMachine(holdDuration: 0.3)
        // Button 3 down at t = 1.0
        _ = stateMachine.handleInput(button: 3, isDown: true, atTime: 1.0)
        XCTAssertTrue(stateMachine.isTracked(button: 3))

        // Button 3 up at t = 1.15 (150ms later, quick click)
        let result = stateMachine.handleInput(button: 3, isDown: false, atTime: 1.15)
        XCTAssertEqual(result, .action(.moveRightSpace))
        XCTAssertFalse(stateMachine.isTracked(button: 3))
    }

    func testMiddleClickWithoutActionReplaysDefaultClick() {
        let stateMachine = ButtonStateMachine(holdDuration: 0.3)
        // Button 2 (Middle Click) has clickAction == nil in defaults
        _ = stateMachine.handleInput(button: 2, isDown: true, atTime: 1.0)
        XCTAssertTrue(stateMachine.isTracked(button: 2))

        // Released quickly -> should return .defaultClick to open tab in Chrome
        let result = stateMachine.handleInput(button: 2, isDown: false, atTime: 1.1)
        XCTAssertEqual(result, .defaultClick)
        XCTAssertFalse(stateMachine.isTracked(button: 2))
    }

    func testHoldTriggersHoldActionAndReleasesWithNone() {
        let stateMachine = ButtonStateMachine(holdDuration: 0.3)
        // Button 3 down at t = 1.0
        _ = stateMachine.handleInput(button: 3, isDown: true, atTime: 1.0)

        // Hold timer checks at t = 1.2 (< 300ms)
        let earlyCheck = stateMachine.checkHoldTimeout(button: 3, atTime: 1.2)
        XCTAssertNil(earlyCheck)

        // Hold timer checks at t = 1.35 (> 300ms)
        let holdAction = stateMachine.checkHoldTimeout(button: 3, atTime: 1.35)
        XCTAssertEqual(holdAction, .appExpose)

        // Button 3 up at t = 1.5 should return .none (no default click or double trigger)
        let upResult = stateMachine.handleInput(button: 3, isDown: false, atTime: 1.5)
        XCTAssertEqual(upResult, .none)
    }

    func testUnmappedButtonReturnsDefaultClick() {
        let stateMachine = ButtonStateMachine()
        let result = stateMachine.handleInput(button: 99, isDown: false, atTime: 1.0)
        XCTAssertEqual(result, .defaultClick)
    }
}
