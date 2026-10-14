# MouseFix

A lightweight macOS utility inspired by Mac Mouse Fix, built using Swift and reverse-engineered architecture patterns via REA.

## Features

- **Natural Smooth Scrolling:** Intercepts discrete stepped mouse wheel ticks at the `CGEventTap` layer and synthesizes continuous, trackpad-like subpixel scroll events with physics-based deceleration and momentum.
- **Direction Inversion:** Allows natural scrolling direction on mouse wheels independently of macOS trackpad preferences.
- **Shift-to-Horizontal:** Swaps vertical wheel deltas to horizontal scrolling when Shift is held.
- **Spaces & Window Navigation (Default Mappings):**
  - **Button 4 (Back):** Click moves Right a space (`Ctrl + Right`); Hold opens Application Windows (App Exposé).
  - **Button 5 (Forward):** Click moves Left a space (`Ctrl + Left`); Hold opens Mission Control (`Ctrl + Up`).
  - **Button 3 (Middle):** Hold triggers Mission Control.
- **Native SwiftUI Settings UI:** Visual configuration window with real-time editing of button mappings, scroll speed, and hold duration.
- **Zero Kernel Extensions / Low Footprint:** Operates purely through CoreGraphics event taps and native gesture event simulation (`kCGEventGesture`).
- **Background Daemon Support:** Can be installed directly as a user LaunchAgent via `--install-daemon`.

## Building & Testing

```bash
# Run unit tests
swift test

# Build release binaries
swift build -c release
```

## Running the Graphical Settings App

```bash
# Launch the SwiftUI settings UI
./.build/release/MouseFixApp
```

## Running the CLI Daemon

```bash
# Run in foreground (requires Accessibility permissions)
./.build/release/mousefix

# View current JSON configuration
./.build/release/mousefix --config

# Open configuration in your default editor
./.build/release/mousefix --edit-config

# Install as background LaunchAgent login item
./.build/release/mousefix --install-daemon

# Remove LaunchAgent
./.build/release/mousefix --uninstall-daemon
```
