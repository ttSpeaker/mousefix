import Foundation
import CoreGraphics
import MouseFixCore
import QuartzCore
import AppKit

let args = CommandLine.arguments

if args.contains("--config") {
    let config = AppConfig.load()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let data = try? encoder.encode(config), let json = String(data: data, encoding: .utf8) {
        print("Config file: \(AppConfig.defaultConfigURL.path)\n")
        print(json)
    }
    exit(0)
}

if args.contains("--edit-config") {
    _ = AppConfig.load() // Ensure file exists
    NSWorkspace.shared.open(AppConfig.defaultConfigURL)
    print("Opened \(AppConfig.defaultConfigURL.path)")
    exit(0)
}

if args.contains("--install-daemon") {
    let binaryPath = Bundle.main.executablePath ?? args[0]
    do {
        try LaunchdService.install(executablePath: binaryPath)
        print("Installed LaunchAgent at: \(LaunchdService.plistURL.path)")
        print("To load: launchctl load \(LaunchdService.plistURL.path)")
    } catch {
        FileHandle.standardError.write(Data("Error installing LaunchAgent: \(error)\n".utf8))
        exit(1)
    }
    exit(0)
}

if args.contains("--uninstall-daemon") {
    do {
        try LaunchdService.uninstall()
        print("Uninstalled LaunchAgent at: \(LaunchdService.plistURL.path)")
    } catch {
        FileHandle.standardError.write(Data("Error uninstalling LaunchAgent: \(error)\n".utf8))
        exit(1)
    }
    exit(0)
}

guard Permission.isAccessibilityTrusted(prompt: true) else {
    FileHandle.standardError.write(Data("Accessibility permission required. Please grant permission in System Settings -> Privacy & Security -> Accessibility.\n".utf8))
    exit(1)
}

let config = AppConfig.load()
let scrollEngine = SmoothScrollEngine(config: config.scroll)
let buttonStateMachine = ButtonStateMachine(mappings: config.buttons, holdDuration: config.holdDuration)
let buttonQueue = DispatchQueue(label: "mousefix.buttons", qos: .userInteractive)
var holdItems: [Int: DispatchWorkItem] = [:]

let manager = EventTapManager()

let started = manager.start { type, event in
    let classification = EventTapFilter.classify(type: type, event: event)
    switch classification {
    case .interceptScroll(let dy, let dx):
        let shiftPressed = event.flags.contains(.maskShift)
        scrollEngine.handleScrollTick(rawDeltaY: dy, rawDeltaX: dx, shiftPressed: shiftPressed)
        return nil

    case .interceptButton(let button, let isDown):
        guard buttonStateMachine.mappings[button] != nil else {
            return event
        }

        let now = CACurrentMediaTime()
        if isDown {
            _ = buttonStateMachine.handleInput(button: button, isDown: true, atTime: now)
            let item = DispatchWorkItem {
                if let holdAction = buttonStateMachine.checkHoldTimeout(button: button, atTime: CACurrentMediaTime()) {
                    ActionSimulator.execute(action: holdAction)
                }
            }
            holdItems[button] = item
            buttonQueue.asyncAfter(deadline: .now() + buttonStateMachine.holdDuration, execute: item)
        } else {
            holdItems[button]?.cancel()
            holdItems.removeValue(forKey: button)
            let releaseResult = buttonStateMachine.handleInput(button: button, isDown: false, atTime: now)
            switch releaseResult {
            case .action(let clickAction):
                ActionSimulator.execute(action: clickAction)
            case .defaultClick:
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

guard started else {
    FileHandle.standardError.write(Data("Failed to initialize CGEventTap. Verify Accessibility privileges.\n".utf8))
    exit(1)
}

print("MouseFix daemon active:")
print(" - Natural smooth scrolling: \(config.scroll.invertDirection ? "Enabled" : "Disabled")")
print(" - Button 3 (Middle): Click=\(config.buttons[2]?.clickAction?.displayName ?? "none"), Hold=\(config.buttons[2]?.holdAction?.displayName ?? "none")")
print(" - Button 4 (Back): Click=\(config.buttons[3]?.clickAction?.displayName ?? "none"), Hold=\(config.buttons[3]?.holdAction?.displayName ?? "none")")
print(" - Button 5 (Forward): Click=\(config.buttons[4]?.clickAction?.displayName ?? "none"), Hold=\(config.buttons[4]?.holdAction?.displayName ?? "none")")
print("Config path: \(AppConfig.defaultConfigURL.path)")

CFRunLoopRun()
