# MouseFix Project Instructions

This project is a native Swift/SwiftUI reimplementation of Mac Mouse Fix for macOS, providing trackpad-style smooth scrolling, mouse button remapping, and system gesture navigation.

---

## Architecture & Conventions

- **Targets:**
  - `MouseFixCore`: Shared library containing the low-level `CGEventTap` manager, physics engine, button state machine, configuration persistence, and SkyLight `SymbolicHotKeys` bridge.
  - `MouseFixApp`: macOS SwiftUI settings application with Menu Bar status companion (`NSStatusItem`).
  - `MouseFix`: Lightweight headless CLI daemon and launchd runner.
  - `MouseFixTests`: Automated unit test suite with XCTest.

- **Event Routing & Security Rules:**
  - **Interception:** Event tap listens at `.cghidEventTap` using `CGEvent.tapCreate`.
  - **Posting:** Continuous scroll events and symbolic hotkeys MUST be posted to `.cgSessionEventTap`.
  - **Recursion Guard:** All synthetic events MUST be tagged with `EventTapFilter.magicUserData` (`0x4D4D4658`). The filter passes them through unconditionally.
  - **System Gestures (Spaces / Mission Control):** Never use simulated keyboard chords (`Ctrl + Arrow`). Use `SymbolicHotKeys.post(hotKey:)` with SkyLight CGS symbolic hotkeys (79 = Left Space, 81 = Right Space, 32 = Mission Control, 33 = App Exposé).
  - **Middle Click:** Buttons with `holdAction` but no custom `clickAction` must invoke `ActionSimulator.postRawButtonClick(button:)` on quick release so native browser middle-clicks work normally.

---

## Build & Testing Workflows

- **Run Tests:**
  ```bash
  swift test
  ```
- **Build & Package App:**
  Always use the bundling script (which signs the bundle with ad-hoc identity to satisfy macOS TCC):
  ```bash
  bash scripts/bundle-app.sh
  ```
- **Launch App:**
  ```bash
  open MouseFix.app
  ```

---

## Documentation & Detailed Specs

- See `README.md` for end-user setup, Accessibility permissions, and CLI usage.
- See `docs/HANDOFF.md` for deep reverse-engineered analysis notes from Mac Mouse Fix, subpixel math, and the next-iteration roadmap.
