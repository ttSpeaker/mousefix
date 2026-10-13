import XCTest
@testable import MouseFixCore

final class ButtonStateMachineTests: XCTestCase {
    func testClickTriggersClickAction() {
        let stateMachine = ButtonStateMachine(holdDuration: 0.3)
        // Button 3 down at t = 1.0
        _ = stateMachine.handleInput(button: 3, isDown: true, atTime: 1.0)
        XCTAssertTrue(stateMachine.isTracked(button: 3))

        // Button 3 up at t = 1.15 (150ms later, quick click)
        let action = stateMachine.handleInput(button: 3, isDown: false, atTime: 1.15)
        XCTAssertEqual(action, .swipeBack)
        XCTAssertFalse(stateMachine.isTracked(button: 3))
    }

    func testHoldTriggersHoldAction() {
        let stateMachine = ButtonStateMachine(holdDuration: 0.3)
        // Button 3 down at t = 1.0
        _ = stateMachine.handleInput(button: 3, isDown: true, atTime: 1.0)

        // Hold timer checks at t = 1.2 (< 300ms)
        let earlyCheck = stateMachine.checkHoldTimeout(button: 3, atTime: 1.2)
        XCTAssertNil(earlyCheck)

        // Hold timer checks at t = 1.35 (> 300ms)
        let holdAction = stateMachine.checkHoldTimeout(button: 3, atTime: 1.35)
        XCTAssertEqual(holdAction, .missionControl)

        // Button 3 up at t = 1.5 should not trigger click again
        let upAction = stateMachine.handleInput(button: 3, isDown: false, atTime: 1.5)
        XCTAssertNil(upAction)
    }

    func testUnmappedButtonReturnsNil() {
        let stateMachine = ButtonStateMachine()
        let action = stateMachine.handleInput(button: 99, isDown: true, atTime: 1.0)
        XCTAssertNil(action)
    }
}
