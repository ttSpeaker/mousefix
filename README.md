# MouseFix

A lightweight, native macOS mouse utility inspired by **Mac Mouse Fix**, built with Swift, SwiftUI, and reverse-engineered architecture patterns via REA.

---

## Features

- **Smooth Trackpad Scrolling:** Intercepts stepped mouse wheel clicks at `kCGHIDEventTap` and synthesizes continuous, inertia-driven trackpad scroll events (`isContinuous == 1`) with momentum and subpixel accumulation.
- **Independent Natural Scrolling:** Invert mouse wheel direction without affecting your built-in trackpad settings.
- **Horizontal Scroll via Shift:** Hold `Shift` while scrolling to pan horizontally.
- **Desktop Spaces & Window Gestures:**
  - **Button 4 (Thumb - Back):** Click switches to **Right Desktop Space**; Hold opens **Application Windows (App Exposé)**.
  - **Button 5 (Thumb - Forward):** Click switches to **Left Desktop Space**; Hold opens **Mission Control**.
  - **Button 3 (Middle Click):** Click acts as genuine **Middle Click** (opens/closes browser tabs); Hold triggers **Mission Control**.
  - Powered by macOS `SkyLight` Symbolic Hotkeys (`CGSSetSymbolicHotKeyValue`) for instant, reliable WindowServer desktop transitions.
- **Menu Bar Companion:** Lives unobtrusively in your macOS Menu Bar with live status, fast access to settings, and quit options.
- **Background Execution:** Closing the settings window hides it to the background while the interception engine keeps running.
- **Launch on Startup:** Built-in toggle supporting native macOS Login Items (`SMAppService`) and user `LaunchAgent`.
- **Live Input Monitor:** Real-time feedback bar identifying mouse buttons, click/hold states, and wheel movements.
- **Zero Kernel Extensions:** 100% user-space CoreGraphics event tap architecture.

---

## Quick Start: Building & Launching the App

### 1. Build and Package `MouseFix.app`
Run the bundling script to compile the release binary, package it into `MouseFix.app`, and apply local code-signing:

```bash
bash scripts/bundle-app.sh
```

### 2. Launch MouseFix
```bash
open MouseFix.app
```

---

## Granting Accessibility Permissions

macOS requires **Accessibility** access for mouse utilities to intercept hardware wheel and button events:

1. When you first launch `MouseFix.app`, macOS will prompt for Accessibility permissions (or click **"Open Settings"** on the banner in MouseFix).
2. Go to **System Settings → Privacy & Security → Accessibility**.
3. Toggle the switch next to **MouseFix** to **ON**.
4. The live indicator at the top of the MouseFix window will turn **🟢 Active**.

> **Note for Local Development:**  
> When rebuilding an ad-hoc signed app locally, macOS binds permissions to the exact binary hash (`cdhash`). If you recompile the app, simply toggle the switch **OFF and back ON** in System Settings once so macOS registers the new binary.

---

## Running in the Background & Menu Bar

- **Closing the Window:** Clicking the red `(X)` close button hides the window without stopping MouseFix. The mouse interception and smooth scrolling remain fully active.
- **Menu Bar Icon:** Click the mouse icon in your macOS top menu bar to:
  - Check current status (`🟢 Active` / `🔴 Needs Permission`).
  - Open Settings (`Cmd + ,`).
  - Toggle **Launch at Login**.
  - **Quit MouseFix** (`Cmd + Q`).
- **Restoring Settings:** Re-open the window by clicking the Menu Bar icon and selecting **Open Settings...**, or by clicking the app icon in Finder/Dock.

---

## Launch on Startup

You can set MouseFix to start automatically upon login using either method:

### In the Graphical App
1. Open **MouseFix Settings → General** (or click the Menu Bar icon).
2. Enable the **"Launch MouseFix on System Startup"** toggle.
3. This registers MouseFix directly into **System Settings → General → Login Items & Extensions**.

### Via the CLI Daemon (Headless)
If you prefer running MouseFix purely as a background headless daemon:
```bash
# Build release binaries
swift build -c release

# Install and start the LaunchAgent daemon
./.build/release/mousefix --install-daemon
launchctl load ~/Library/LaunchAgents/com.user.mousefix.plist

# Stop and uninstall the daemon
launchctl unload ~/Library/LaunchAgents/com.user.mousefix.plist
./.build/release/mousefix --uninstall-daemon
```

---

## Configuration

MouseFix stores configuration in human-readable JSON format at:
```
~/.config/mousefix/config.json
```

You can view or edit it directly from the CLI:
```bash
# Display active JSON configuration
./.build/release/mousefix --config

# Open config.json in your default editor
./.build/release/mousefix --edit-config
```

### Default Button Mapping Reference
| Button Number | Hardware Physical Key | Click Action | Hold Action (> 0.3s) |
| :--- | :--- | :--- | :--- |
| **Button 2** | Button 3 (Middle Click / Wheel) | Native Middle Click | Mission Control |
| **Button 3** | Button 4 (Thumb Back / Lower) | Move Right a Space | App Exposé |
| **Button 4** | Button 5 (Thumb Forward / Upper) | Move Left a Space | Mission Control |

---

## Testing

MouseFix includes an automated XCTest suite verifying physics deceleration, subpixel accumulation, event tap classification, state machines, and serialization:

```bash
swift test
```
