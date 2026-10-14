import SwiftUI
import AppKit
import MouseFixCore

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var settingsWindow: NSWindow?
    var statusItem: NSStatusItem?
    var appState: AppState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupStatusItem()
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.isReleasedWhenClosed = false
                self.settingsWindow = window
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "MouseFix")
        }

        let menu = NSMenu()
        menu.delegate = self

        let statusMenuItem = NSMenuItem(title: currentStatusText(), action: nil, keyEquivalent: "")
        statusMenuItem.tag = 100
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())

        let openItem = NSMenuItem(title: "Open Settings...", action: #selector(openSettingsAction), keyEquivalent: ",")
        openItem.target = self
        menu.addItem(openItem)

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLoginAction(_:)), keyEquivalent: "")
        loginItem.target = self
        loginItem.tag = 101
        loginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit MouseFix", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func currentStatusText() -> String {
        let isGranted = appState?.isAccessibilityGranted ?? Permission.isAccessibilityTrusted()
        return isGranted ? "MouseFix: Active 🟢" : "MouseFix: Needs Permission 🔴"
    }

    func menuWillOpen(_ menu: NSMenu) {
        if let statusItem = menu.item(withTag: 100) {
            statusItem.title = currentStatusText()
        }
        if let loginItem = menu.item(withTag: 101) {
            loginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        }
    }

    @objc func openSettingsAction() {
        showSettingsWindow()
    }

    @objc func toggleLaunchAtLoginAction(_ sender: NSMenuItem) {
        let newState = !LaunchAtLogin.isEnabled
        LaunchAtLogin.isEnabled = newState
        sender.state = newState ? .on : .off
        appState?.launchAtLogin = newState
    }

    @objc func quitAction() {
        NSApp.terminate(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Stay running in background
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showSettingsWindow()
        }
        return true
    }

    func showSettingsWindow() {
        if let window = settingsWindow ?? NSApp.windows.first {
            window.isReleasedWhenClosed = false
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
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
                .onAppear {
                    appDelegate.appState = appState
                    DispatchQueue.main.async {
                        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                            window.isReleasedWhenClosed = false
                            appDelegate.settingsWindow = window
                        }
                    }
                }
        }
    }
}
