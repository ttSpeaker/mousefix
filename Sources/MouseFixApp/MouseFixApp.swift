import SwiftUI
import AppKit
import MouseFixCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct MouseFixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            SettingsView(appState: appState)
                .navigationTitle("MouseFix Settings")
        }
    }
}
