import CoreGraphics
import Foundation

public struct ActionSimulator {
    public static func postNavigationSwipe(forward: Bool) {
        guard let event = CGEvent(source: nil) else { return }
        let direction: Int64 = forward ? 1 : -1
        event.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        event.setIntegerValueField(CGEventField(rawValue: 55)!, value: 29) // kCGEventGesture
        event.setIntegerValueField(CGEventField(rawValue: 110)!, value: 16) // swipe
        event.setIntegerValueField(CGEventField(rawValue: 132)!, value: 1) // began
        event.setIntegerValueField(CGEventField(rawValue: 115)!, value: direction)
        event.post(tap: .cgSessionEventTap)

        event.setIntegerValueField(CGEventField(rawValue: 115)!, value: 0)
        event.setIntegerValueField(CGEventField(rawValue: 132)!, value: 4) // ended
        event.post(tap: .cgSessionEventTap)
    }

    public static func postSmartZoom() {
        guard let event = CGEvent(source: nil) else { return }
        event.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        event.setIntegerValueField(CGEventField(rawValue: 55)!, value: 29) // kCGEventGesture
        event.setIntegerValueField(CGEventField(rawValue: 110)!, value: 22) // smart zoom
        event.post(tap: .cgSessionEventTap)
    }

    public static func postRawButtonClick(button: Int) {
        let mouseLocation = CGEvent(source: nil)?.location ?? .zero

        guard let down = CGEvent(
            mouseEventSource: nil,
            mouseType: .otherMouseDown,
            mouseCursorPosition: mouseLocation,
            mouseButton: CGMouseButton(rawValue: UInt32(button)) ?? .center
        ),
        let up = CGEvent(
            mouseEventSource: nil,
            mouseType: .otherMouseUp,
            mouseCursorPosition: mouseLocation,
            mouseButton: CGMouseButton(rawValue: UInt32(button)) ?? .center
        ) else { return }

        down.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        up.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        down.setIntegerValueField(.mouseEventButtonNumber, value: Int64(button))
        up.setIntegerValueField(.mouseEventButtonNumber, value: Int64(button))

        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    public static func execute(action: ButtonAction) {
        switch action {
        case .moveLeftSpace:
            SymbolicHotKeys.post(hotKey: 79) // Move Left a Space
        case .moveRightSpace:
            SymbolicHotKeys.post(hotKey: 81) // Move Right a Space
        case .missionControl:
            SymbolicHotKeys.post(hotKey: 32) // Mission Control
        case .appExpose:
            SymbolicHotKeys.post(hotKey: 33) // Application Windows (App Exposé)
        case .showDesktop:
            SymbolicHotKeys.post(hotKey: 36) // Show Desktop
        case .swipeBack:
            postNavigationSwipe(forward: false)
        case .swipeForward:
            postNavigationSwipe(forward: true)
        case .smartZoom:
            postSmartZoom()
        }
    }
}
