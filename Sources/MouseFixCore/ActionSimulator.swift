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

    public static func postKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else { return }
        down.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        up.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        down.flags = flags
        up.flags = []
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    public static func execute(action: ButtonAction) {
        switch action {
        case .swipeBack: postNavigationSwipe(forward: false)
        case .swipeForward: postNavigationSwipe(forward: true)
        case .smartZoom: postSmartZoom()
        case .missionControl: postKeyPress(keyCode: 0x7E, flags: .maskControl)
        case .appExpose: postKeyPress(keyCode: 0x7D, flags: .maskControl)
        case .showDesktop: postKeyPress(keyCode: 0x67, flags: [])
        case .customKey(let keyCode, let flags): postKeyPress(keyCode: keyCode, flags: CGEventFlags(rawValue: flags))
        }
    }
}
