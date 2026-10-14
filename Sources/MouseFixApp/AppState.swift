import Foundation
import CoreGraphics
import MouseFixCore
import QuartzCore
import Combine
import AppKit

public final class AppState: ObservableObject {
    @Published public var config: AppConfig {
        didSet {
            try? config.save()
            reconfigureEngine()
        }
    }
    @Published public var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                startService()
            } else {
                stopService()
            }
        }
    }
    @Published public var isAccessibilityGranted: Bool = false
    @Published public var lastDetectedInput: String = "Waiting for mouse input..."
    @Published public var lastDetectedButton: Int? = nil

    private var eventTapManager = EventTapManager()
    private var scrollEngine: SmoothScrollEngine
    private var buttonStateMachine: ButtonStateMachine
    private let buttonQueue = DispatchQueue(label: "mousefix.app.buttons", qos: .userInteractive)
    private var holdItems: [Int: DispatchWorkItem] = [:]
    private var permissionTimer: AnyCancellable?

    public init() {
        let loadedConfig = AppConfig.load()
        self.config = loadedConfig
        self.scrollEngine = SmoothScrollEngine(config: loadedConfig.scroll)
        self.buttonStateMachine = ButtonStateMachine(mappings: loadedConfig.buttons, holdDuration: loadedConfig.holdDuration)
        
        // Initial attempt to start service
        startService()
        if !isAccessibilityGranted {
            _ = Permission.isAccessibilityTrusted(prompt: true)
            startPermissionPolling()
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.startService()
        }
    }

    public func startPermissionPolling() {
        permissionTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !self.isAccessibilityGranted {
                    self.startService()
                }
            }
    }

    public func openAccessibilitySettings() {
        _ = Permission.isAccessibilityTrusted(prompt: true)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    public func reconfigureEngine() {
        scrollEngine.config = config.scroll
        buttonStateMachine.mappings = config.buttons
        buttonStateMachine.holdDuration = config.holdDuration
    }

    public func buttonDescription(for button: Int) -> String {
        switch button {
        case 2: return "Middle Click (Scroll Wheel)"
        case 3: return "Button 4 (Thumb - Back / Lower Side)"
        case 4: return "Button 5 (Thumb - Forward / Upper Side)"
        default: return "Button \(button + 1)"
        }
    }

    public func startService() {
        stopService()

        let started = eventTapManager.start { [weak self] type, event in
            guard let self = self, self.isEnabled else { return event }
            let classification = EventTapFilter.classify(type: type, event: event)

            switch classification {
            case .interceptScroll(let dy, let dx):
                let shiftPressed = event.flags.contains(.maskShift)
                self.scrollEngine.handleScrollTick(rawDeltaY: dy, rawDeltaX: dx, shiftPressed: shiftPressed)
                DispatchQueue.main.async {
                    self.lastDetectedInput = "Scroll Wheel: Dy=\(dy) Dx=\(dx) (Smoothed)"
                }
                return nil

            case .interceptButton(let button, let isDown):
                let desc = self.buttonDescription(for: button)
                DispatchQueue.main.async {
                    self.lastDetectedInput = "\(desc): \(isDown ? "Down" : "Up")"
                    self.lastDetectedButton = button
                }

                guard self.buttonStateMachine.mappings[button] != nil else {
                    return event
                }

                let now = CACurrentMediaTime()
                if isDown {
                    _ = self.buttonStateMachine.handleInput(button: button, isDown: true, atTime: now)
                    let item = DispatchWorkItem { [weak self] in
                        guard let self = self else { return }
                        if let holdAction = self.buttonStateMachine.checkHoldTimeout(button: button, atTime: CACurrentMediaTime()) {
                            DispatchQueue.main.async {
                                self.lastDetectedInput = "\(desc): Held -> Triggered \(holdAction.displayName)"
                            }
                            ActionSimulator.execute(action: holdAction)
                        }
                    }
                    self.holdItems[button] = item
                    self.buttonQueue.asyncAfter(deadline: .now() + self.buttonStateMachine.holdDuration, execute: item)
                } else {
                    self.holdItems[button]?.cancel()
                    self.holdItems.removeValue(forKey: button)
                    let releaseResult = self.buttonStateMachine.handleInput(button: button, isDown: false, atTime: now)
                    switch releaseResult {
                    case .action(let clickAction):
                        DispatchQueue.main.async {
                            self.lastDetectedInput = "\(desc): Click -> Triggered \(clickAction.displayName)"
                        }
                        ActionSimulator.execute(action: clickAction)
                    case .defaultClick:
                        DispatchQueue.main.async {
                            self.lastDetectedInput = "\(desc): Click -> Standard Middle/Mouse Click"
                        }
                        ActionSimulator.postRawButtonClick(button: button)
                    case .none:
                        break
                    }
                }
                return nil

            case .passThrough:
                return event
            }
        }

        if started {
            self.isAccessibilityGranted = true
            self.permissionTimer?.cancel()
            self.permissionTimer = nil
            self.lastDetectedInput = "MouseFix is active and intercepting."
        } else {
            self.isAccessibilityGranted = false
            self.lastDetectedInput = "Waiting for Accessibility permission..."
        }
    }

    public func stopService() {
        eventTapManager.stop()
        holdItems.values.forEach { $0.cancel() }
        holdItems.removeAll()
    }
}
