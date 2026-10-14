import SwiftUI
import MouseFixCore

public struct SettingsView: View {
    @ObservedObject var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            if !appState.isAccessibilityGranted {
                permissionWarningBanner
            }

            liveMonitorBar

            TabView {
                buttonsTab
                    .tabItem {
                        Label("Buttons", systemImage: "computermouse")
                    }

                scrollTab
                    .tabItem {
                        Label("Scroll", systemImage: "arrow.up.and.down")
                    }

                generalTab
                    .tabItem {
                        Label("General", systemImage: "gearshape")
                    }
            }
            .padding()
        }
        .frame(width: 520, height: 500)
    }

    private var permissionWarningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Accessibility Permission Required")
                    .font(.headline)
                Text("MouseFix cannot intercept buttons or smooth scrolling until granted in macOS System Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Open Settings") {
                appState.openAccessibilitySettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.orange.opacity(0.12))
        .cornerRadius(8)
        .padding([.top, .horizontal])
    }

    private var liveMonitorBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(appState.isAccessibilityGranted ? Color.green : Color.red)
                .frame(width: 10, height: 10)

            Text("Live Input:")
                .font(.subheadline)
                .bold()

            Text(appState.lastDetectedInput)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            if appState.isAccessibilityGranted {
                Text("Active")
                    .font(.caption)
                    .foregroundColor(.green)
                    .bold()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var buttonsTab: some View {
        Form {
            Section {
                actionPicker(title: "Click Action", selection: buttonClickBinding(for: 3))
                actionPicker(title: "Hold Action", selection: buttonHoldBinding(for: 3))
            } header: {
                HStack {
                    Text("Button 4 — Thumb Back (Lower Side Button)")
                        .bold()
                    if appState.lastDetectedButton == 3 {
                        Text("Pressed").font(.caption).foregroundColor(.blue).bold()
                    }
                }
            }

            Section {
                actionPicker(title: "Click Action", selection: buttonClickBinding(for: 4))
                actionPicker(title: "Hold Action", selection: buttonHoldBinding(for: 4))
            } header: {
                HStack {
                    Text("Button 5 — Thumb Forward (Upper Side Button)")
                        .bold()
                    if appState.lastDetectedButton == 4 {
                        Text("Pressed").font(.caption).foregroundColor(.blue).bold()
                    }
                }
            }

            Section {
                actionPicker(title: "Click Action", selection: buttonClickBinding(for: 2))
                actionPicker(title: "Hold Action", selection: buttonHoldBinding(for: 2))
            } header: {
                HStack {
                    Text("Button 3 — Middle Click (Scroll Wheel Click)")
                        .bold()
                    if appState.lastDetectedButton == 2 {
                        Text("Pressed").font(.caption).foregroundColor(.blue).bold()
                    }
                }
            }

            Section(header: Text("Timing")) {
                HStack {
                    Text("Hold Threshold: \(String(format: "%.2f", appState.config.holdDuration))s")
                    Slider(value: $appState.config.holdDuration, in: 0.15...0.8, step: 0.05)
                }
            }
        }
    }

    private var scrollTab: some View {
        Form {
            Section(header: Text("Smooth Scrolling Engine")) {
                Toggle("Invert Direction (Natural Scrolling)", isOn: $appState.config.scroll.invertDirection)
                Toggle("Shift + Scroll for Horizontal", isOn: $appState.config.scroll.swapAxesOnShift)
                HStack {
                    Text("Scroll Speed / Step: \(Int(appState.config.scroll.stepSize)) px")
                    Slider(value: $appState.config.scroll.stepSize, in: 15...80, step: 5)
                }
            }
        }
    }

    private var generalTab: some View {
        Form {
            Section(header: Text("Service Status")) {
                Toggle("Enable Interception", isOn: $appState.isEnabled)
            }

            Section(header: Text("Startup")) {
                Toggle("Launch MouseFix on System Startup", isOn: $appState.launchAtLogin)
                Text("Registered with macOS Login Items. MouseFix will launch automatically when you log in.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Background Execution")) {
                Text("Closing this settings window keeps MouseFix running smoothly in your Menu Bar. To quit completely, click the mouse icon in your top menu bar and select Quit MouseFix.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Configuration")) {
                Button("Open config.json in Editor") {
                    NSWorkspace.shared.open(AppConfig.defaultConfigURL)
                }
                Button("Reset to Defaults", role: .destructive) {
                    appState.config = AppConfig()
                }
            }
        }
    }

    private func actionPicker(title: String, selection: Binding<ButtonAction?>) -> some View {
        Picker(title, selection: selection) {
            Text("None").tag(ButtonAction?.none)
            Divider()
            ForEach(ButtonAction.allCases, id: \.self) { action in
                Text(action.displayName).tag(ButtonAction?.some(action))
            }
        }
    }

    private func buttonClickBinding(for button: Int) -> Binding<ButtonAction?> {
        Binding(
            get: { appState.config.buttons[button]?.clickAction },
            set: { newAction in
                var mapping = appState.config.buttons[button] ?? ButtonMapping(button: button)
                mapping.clickAction = newAction
                appState.config.buttons[button] = mapping
            }
        )
    }

    private func buttonHoldBinding(for button: Int) -> Binding<ButtonAction?> {
        Binding(
            get: { appState.config.buttons[button]?.holdAction },
            set: { newAction in
                var mapping = appState.config.buttons[button] ?? ButtonMapping(button: button)
                mapping.holdAction = newAction
                appState.config.buttons[button] = mapping
            }
        )
    }
}
