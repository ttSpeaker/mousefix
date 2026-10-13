import CoreGraphics
import Foundation

public enum EventClassification: Equatable {
    case passThrough
    case interceptScroll(deltaY: Int64, deltaX: Int64)
    case interceptButton(button: Int, isDown: Bool)
}

public struct EventTapFilter {
    public static let magicUserData: Int64 = 0x4D4D4658 // 'MMFX'

    public static func classify(type: CGEventType, event: CGEvent) -> EventClassification {
        let userData = event.getIntegerValueField(.eventSourceUserData)
        if userData == magicUserData {
            return .passThrough
        }

        switch type {
        case .scrollWheel:
            let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous)
            let momentumPhase = event.getIntegerValueField(.scrollWheelEventMomentumPhase)
            if isContinuous == 0 && momentumPhase == 0 {
                let dy = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                let dx = event.getIntegerValueField(.scrollWheelEventDeltaAxis2)
                return .interceptScroll(deltaY: dy, deltaX: dx)
            }
            return .passThrough

        case .otherMouseDown, .otherMouseUp:
            let button = Int(event.getIntegerValueField(.mouseEventButtonNumber))
            if button >= 2 {
                return .interceptButton(button: button, isDown: type == .otherMouseDown)
            }
            return .passThrough

        default:
            return .passThrough
        }
    }
}
