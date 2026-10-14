import Foundation
import ServiceManagement

public enum LaunchAtLogin {
    public static var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                let status = SMAppService.mainApp.status
                if status == .enabled { return true }
            }
            return FileManager.default.fileExists(atPath: LaunchdService.plistURL.path)
        }
        set {
            if #available(macOS 13.0, *) {
                if newValue {
                    do {
                        try SMAppService.mainApp.register()
                        return
                    } catch {
                        // Fallback to LaunchAgent if SMAppService throws in dev build
                    }
                } else {
                    try? SMAppService.mainApp.unregister()
                    try? LaunchdService.uninstall()
                    return
                }
            }
            if newValue {
                let execPath = Bundle.main.executablePath ?? "/Applications/MouseFix.app/Contents/MacOS/MouseFix"
                try? LaunchdService.install(executablePath: execPath)
            } else {
                try? LaunchdService.uninstall()
            }
        }
    }
}
