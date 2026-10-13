import XCTest
import CoreGraphics
@testable import MouseFixCore

final class EventTapFilterTests: XCTestCase {
    func testSteppedScrollWheelIsIntercepted() {
        guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: -1, wheel2: 0, wheel3: 0) else {
            XCTFail("Failed to create scroll event")
            return
        }
        event.setIntegerValueField(.scrollWheelEventIsContinuous, value: 0)
        event.setIntegerValueField(.scrollWheelEventMomentumPhase, value: 0)

        let classification = EventTapFilter.classify(type: .scrollWheel, event: event)
        XCTAssertEqual(classification, .interceptScroll(deltaY: -1, deltaX: 0))
    }

    func testContinuousScrollWheelPassesThrough() {
        guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: 10, wheel2: 0, wheel3: 0) else {
            XCTFail("Failed to create scroll event")
            return
        }
        event.setIntegerValueField(.scrollWheelEventIsContinuous, value: 1)

        let classification = EventTapFilter.classify(type: .scrollWheel, event: event)
        XCTAssertEqual(classification, .passThrough)
    }

    func testSyntheticEventWithMagicUserDataPassesThrough() {
        guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: 5, wheel2: 0, wheel3: 0) else {
            XCTFail("Failed to create scroll event")
            return
        }
        event.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)

        let classification = EventTapFilter.classify(type: .scrollWheel, event: event)
        XCTAssertEqual(classification, .passThrough)
    }

    func testSideButtonsAreIntercepted() {
        guard let source = CGEventSource(stateID: .combinedSessionState),
              let event = CGEvent(mouseEventSource: source, mouseType: .otherMouseDown, mouseCursorPosition: .zero, mouseButton: .center) else {
            XCTFail("Failed to create mouse event")
            return
        }
        event.setIntegerValueField(.mouseEventButtonNumber, value: 3) // Back button

        let classification = EventTapFilter.classify(type: .otherMouseDown, event: event)
        XCTAssertEqual(classification, .interceptButton(button: 3, isDown: true))
    }
}
