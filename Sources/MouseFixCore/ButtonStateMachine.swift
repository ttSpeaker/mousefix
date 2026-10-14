import Foundation

public struct ButtonTracker: Sendable {
    public var downTime: TimeInterval
    public var hadEffect: Bool

    public init(downTime: TimeInterval, hadEffect: Bool = false) {
        self.downTime = downTime
        self.hadEffect = hadEffect
    }
}

public enum ButtonReleaseResult: Equatable, Sendable {
    case action(ButtonAction)
    case defaultClick
    case none
}

public final class ButtonStateMachine {
    public var mappings: [Int: ButtonMapping]
    public var holdDuration: TimeInterval
    private var tracking: [Int: ButtonTracker] = [:]

    public init(
        mappings: [Int: ButtonMapping] = ButtonMapping.defaults,
        holdDuration: TimeInterval = 0.3
    ) {
        self.mappings = mappings
        self.holdDuration = holdDuration
    }

    public func handleInput(button: Int, isDown: Bool, atTime: TimeInterval) -> ButtonReleaseResult {
        guard let mapping = mappings[button] else { return .defaultClick }

        if isDown {
            tracking[button] = ButtonTracker(downTime: atTime, hadEffect: false)
            return .none
        } else {
            guard let tracker = tracking.removeValue(forKey: button) else { return .defaultClick }
            if !tracker.hadEffect {
                let duration = atTime - tracker.downTime
                if duration >= holdDuration {
                    if let hold = mapping.holdAction {
                        return .action(hold)
                    }
                    return .none
                } else {
                    if let click = mapping.clickAction {
                        return .action(click)
                    } else {
                        return .defaultClick
                    }
                }
            }
            return .none
        }
    }

    public func checkHoldTimeout(button: Int, atTime: TimeInterval) -> ButtonAction? {
        guard var tracker = tracking[button], !tracker.hadEffect else { return nil }
        guard let mapping = mappings[button] else { return nil }

        if (atTime - tracker.downTime) >= holdDuration {
            tracker.hadEffect = true
            tracking[button] = tracker
            return mapping.holdAction
        }
        return nil
    }

    public func isTracked(button: Int) -> Bool {
        tracking[button] != nil
    }
}
