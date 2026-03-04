# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

GamepadLens is a macOS-only SwiftUI application for real-time visualization and debugging of game controller (gamepad) inputs. It uses Apple's `GameController` framework to detect connected controllers and display button states, thumbstick positions, trigger values, motion sensor data, and an event log.

The UI text is in **简体中文 (Simplified Chinese)**. Keep all user-facing strings in Chinese.

## Build & Run

This is a pure Swift Package Manager project (no `.xcodeproj`). Requires macOS 14+ SDK.

```sh
# Build
swift build

# Run the app (opens a native macOS window)
swift run GamepadLens
```

There are currently no tests or lint configurations in this project.

## Architecture

### Entry Point

`Sources/GamepadLens/GamepadLensApp.swift` — The `@main` SwiftUI `App`. Because this is an SPM executable (not an Xcode app bundle), it manually calls `NSApp.setActivationPolicy(.regular)` on launch to get a proper menu bar and window focus.

### Models (`Sources/GamepadLens/Models/`)

- **`ControllerManager`** — The single source of truth for all gamepad state. Uses the Swift Observation framework (`@Observable`) with `@MainActor` isolation. Responsibilities:
  - Listens for `GCControllerDidConnect` / `GCControllerDidDisconnect` notifications
  - Registers `valueChangedHandler` on `GCExtendedGamepad` and `GCMotion`
  - Exposes all button/axis/motion values as individual `Float`/`Double` properties for direct SwiftUI binding
  - Maintains an event log (`[InputEvent]`, capped at 500 entries)
- **`InputEvent`** — A lightweight `Identifiable` struct representing one input change (timestamp, element name, value, pressed state).

### Views (`Sources/GamepadLens/Views/`)

The UI is a single-window layout split into regions:

- **`ContentView`** — Top-level layout: `ControllerInfoView` on top, then an `HSplitView` with the visualizer on the left and a `VSplitView` (tech data + event log) on the right.
- **`ControllerInfoView`** — Connection status bar with a `Picker` for multiple controllers, vendor/product/battery info. Uses `@Bindable` to bind the selected controller.
- **`GamepadVisualizerView`** — Canvas showing button, trigger, thumbstick, and D-pad state. Composed of reusable sub-views: `ButtonCell`, `TriggerBar`, `ThumbstickView`, `DpadView`, `FaceButtonsView`.
- **`TechnicalDataView`** — Grid of real-time numerical readings (last pressed button, axis values, motion vectors).
- **`EventLogView`** — Scrollable `List` of `InputEvent` records with auto-scroll-to-bottom.

## Git Conventions

All commit messages must be written in **English**.

### Key Patterns

- **No Combine / `ObservableObject`** — The project uses the newer Observation framework exclusively (`@Observable`, `@Bindable`).
- **All controller callbacks dispatch on `DispatchQueue.main`** (`controller.handlerQueue = DispatchQueue.main`) to satisfy `@MainActor` requirements without `MainActor.assumeIsolated`.
- **Element identification** uses a `switch` over `GCControllerElement` identity (`case gamepad.buttonA:`) rather than string-based matching.
