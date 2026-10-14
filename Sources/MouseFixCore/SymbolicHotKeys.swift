import Foundation
import CoreGraphics

public struct SymbolicHotKeys {
    private typealias CGSSetSymbolicHotKeyEnabledFunc = @convention(c) (Int32, Bool) -> Int32
    private typealias CGSSetSymbolicHotKeyValueFunc = @convention(c) (Int32, UniChar, UInt16, UInt64) -> Int32

    private static let setEnabled: CGSSetSymbolicHotKeyEnabledFunc? = {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_NOW),
              let ptr = dlsym(handle, "CGSSetSymbolicHotKeyEnabled") else { return nil }
        return unsafeBitCast(ptr, to: CGSSetSymbolicHotKeyEnabledFunc.self)
    }()

    private static let setValue: CGSSetSymbolicHotKeyValueFunc? = {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_NOW),
              let ptr = dlsym(handle, "CGSSetSymbolicHotKeyValue") else { return nil }
        return unsafeBitCast(ptr, to: CGSSetSymbolicHotKeyValueFunc.self)
    }()

    public static func post(hotKey: Int32) {
        guard let setEnabled = setEnabled, let setValue = setValue else { return }

        let customKeyCode = UInt16((hotKey + 0x190) & 0xffff)
        let modifiers: UInt64 = 0xa00000

        _ = setEnabled(hotKey, true)
        _ = setValue(hotKey, 0xffff, customKeyCode, modifiers)

        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(customKeyCode), keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(customKeyCode), keyDown: false) else { return }

        down.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        up.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        down.flags = CGEventFlags(rawValue: modifiers)
        up.flags = CGEventFlags(rawValue: modifiers)

        down.post(tap: .cgSessionEventTap)
        up.post(tap: .cgSessionEventTap)
    }
}
