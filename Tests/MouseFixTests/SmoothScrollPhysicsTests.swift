import XCTest
@testable import MouseFixCore

final class SmoothScrollPhysicsTests: XCTestCase {
    func testImpulseAndDeceleration() {
        var physics = SmoothScrollPhysics(friction: 0.9, stopThreshold: 0.5)
        physics.addImpulse(deltaY: 10.0, deltaX: 0.0)

        XCTAssertEqual(physics.velocityY, 10.0)

        let step1 = physics.step(deltaTime: 1.0 / 60.0)
        XCTAssertFalse(step1.isFinished)
        XCTAssertEqual(physics.velocityY, 9.0, accuracy: 0.001)

        // Iterate until finished
        var iterations = 0
        var finished = false
        while !finished && iterations < 100 {
            let step = physics.step(deltaTime: 1.0 / 60.0)
            finished = step.isFinished
            iterations += 1
        }

        XCTAssertTrue(finished)
        XCTAssertEqual(physics.velocityY, 0.0)
    }

    func testSubpixelAccumulationPreservesFractionalDeltas() {
        var physics = SmoothScrollPhysics(friction: 1.0, stopThreshold: 0.01)
        // Set velocity to 0.4 pixels per frame so single frame round is 0
        physics.addImpulse(deltaY: 0.4, deltaX: 0.0)

        let step1 = physics.step(deltaTime: 1.0 / 60.0)
        // 0.4 rounds to 0, remainder 0.4
        XCTAssertEqual(step1.dy, 0.0)

        let step2 = physics.step(deltaTime: 1.0 / 60.0)
        // 0.4 + 0.4 = 0.8 rounds to 1, remainder -0.2
        XCTAssertEqual(step2.dy, 1.0)
    }
}
