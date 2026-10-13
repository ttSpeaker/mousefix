# MouseFix

A lightweight macOS utility inspired by Mac Mouse Fix, built using Swift and reverse-engineered architecture patterns via REA.

## Features

- **Natural Smooth Scrolling:** Intercepts discrete stepped mouse wheel ticks at the `CGEventTap` layer and synthesizes continuous, trackpad-like subpixel scroll events with physics-based deceleration and momentum.
- **Direction Inversion:** Allows natural scrolling direction on mouse wheels independently of macOS trackpad preferences.
- **Shift-to-Horizontal:** Swaps vertical wheel deltas to horizontal scrolling when Shift is held.
- **Side Button Remapping:**
  - **Button 4 (Back):** Single click triggers native macOS navigation swipe back (Safari, Finder, Chrome); hold triggers Mission Control.
  - **Button 5 (Forward):** Single click triggers native navigation swipe forward; hold triggers Smart Zoom.
  - **Button 3 (Middle):** Configurable click / hold shortcuts.
- **Zero Kernel Extensions / Low Footprint:** Operates purely through CoreGraphics event taps and native gesture event simulation (`kCGEventGesture`).
- **Background Daemon Support:** Can be installed directly as a user LaunchAgent via `--install-daemon`.

## Architecture

1. **`EventTapManager`:** Sets up `kCGHIDEventTap` with automatic recovery when disabled by system timeout.
2. **`EventTapFilter`:** Categorizes incoming events into pass-through, stepped scroll intercept, and side button intercept. Disregards synthetic events tagged with magic user data (`0x4D4D4658`) to avoid event loops.
3. **`SmoothScrollPhysics` & `SmoothScrollEngine`:** 120Hz timer-driven physics loop with subpixel accumulation and exponential friction.
4. **`ScrollEventPoster`:** Injects continuous `CGEvent` scroll events with `kCGScrollWheelEventIsContinuous = 1`, subpixel point deltas, line deltas, and scroll phases.
5. **`ButtonStateMachine` & `ActionSimulator`:** Dispatches navigation swipes, smart zoom, and keyboard shortcuts based on click vs. hold gestures.
6. **`AppConfig` & `LaunchdService`:** JSON configuration (`~/.config/mousefix/config.json`) and LaunchAgent plist management.

## Building & Testing

```bash
# Run unit tests
swift test

# Build debug binary
swift build

# Build optimized release binary
swift build -c release
```

## Usage

```bash
# Run in foreground (requires Accessibility permissions)
./.build/release/mousefix

# Install as background LaunchAgent login item
./.build/release/mousefix --install-daemon

# Remove LaunchAgent
./.build/release/mousefix --uninstall-daemon
```
