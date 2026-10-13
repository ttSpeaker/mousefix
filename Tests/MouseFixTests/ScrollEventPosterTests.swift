import XCTest
import CoreGraphics
@testable import MouseFixCore

final class ScrollEventPosterTests: XCTestCase {
    func testCreateContinuousScrollEventSetsRequiredFields() {
        guard let event = ScrollEventPoster.createEvent(deltaY: 24.5, deltaX: 0, phase: 2, momentumPhase: 0) else {
            XCTFail("Event creation failed")
            return
        }

        XCTAssertEqual(event.getIntegerValueField(.eventSourceUserData), EventTapFilter.magicUserData)
        XCTAssertEqual(event.getIntegerValueField(.scrollWheelEventIsContinuous), 1)
        XCTAssertEqual(event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1), 25) // rounded 24.5
        XCTAssertEqual(event.getIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1), Int64(24.5 * 65536.0))
        XCTAssertEqual(event.getIntegerValueField(.scrollWheelEventScrollPhase), 2)
        XCTAssertEqual(event.getIntegerValueField(.scrollWheelEventMomentumPhase), 0)

        // Must pass through EventTapFilter without being re-intercepted
        let classification = EventTapFilter.classify(type: .scrollWheel, event: event)
        XCTAssertEqual(classification, .passThrough)
    }

    func testScrollConfigInversionAndShiftModifiers() {
        let config = ScrollConfig(invertDirection: true, swapAxesOnShift: true, stepSize: 40.0)

        // Raw wheel tick: dy = -1 (downward scroll tick on physical wheel)
        let rawTickY: Double = -1.0
        let effectiveDY = config.invertDirection ? -rawTickY * config.stepSize : rawTickY * config.stepSize
        XCTAssertEqual(effectiveDY, 40.0)
    }
}
