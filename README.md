# GamepadLens

A macOS-native SwiftUI application for real-time visualization and debugging of game controller (gamepad) inputs.

Built with Apple's `GameController` framework, GamepadLens detects connected controllers and displays:

- Button states & face buttons
- Thumbstick positions
- Trigger values
- D-pad direction
- Motion sensor data (accelerometer & gyroscope)
- A live event log of all input changes

> **Note:** The application UI is in 简体中文 (Simplified Chinese).

## Requirements

- **macOS 14 (Sonoma)** or later
- **Swift 5.10+** / Xcode 15+

This is a pure Swift Package Manager project — no `.xcodeproj` or `.xcworkspace` required.

## Build & Run

```sh
# Build
swift build

# Run (opens a native macOS window)
swift run GamepadLens
```

You can also open the project directory in Xcode (`File → Open…` → select the repo root) and press **⌘R** to build and run.

## Testing

There are currently no automated tests in this project.

To manually test, connect a game controller (Xbox, PlayStation, MFi, etc.) via Bluetooth or USB and launch the app. All inputs should be reflected in the visualizer, technical data panel, and event log in real time.

## Project Structure

```
Sources/GamepadLens/
├── GamepadLensApp.swift          # @main entry point
├── Models/
│   ├── ControllerManager.swift   # Central gamepad state manager (@Observable)
│   └── InputEvent.swift          # Single input-change record
└── Views/
    ├── ContentView.swift          # Top-level layout
    ├── ControllerInfoView.swift   # Connection status & controller picker
    ├── GamepadVisualizerView.swift # Visual gamepad diagram
    ├── TechnicalDataView.swift    # Numerical readings grid
    └── EventLogView.swift         # Scrollable input event log
```

## Key Design Decisions

- Uses the **Swift Observation framework** (`@Observable` / `@Bindable`) — no Combine or `ObservableObject`.
- Controller callbacks are dispatched on `DispatchQueue.main` to satisfy `@MainActor` isolation.
- Input element identification uses `switch` over `GCControllerElement` identity rather than string-based matching.
- Since the app is built as an SPM executable (not an Xcode app bundle), `NSApp.setActivationPolicy(.regular)` is called at launch to enable proper window focus and menu bar.

## License

This project is licensed under the [MIT License](LICENSE).
