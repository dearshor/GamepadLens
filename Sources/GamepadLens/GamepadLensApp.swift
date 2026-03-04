import SwiftUI
import AppKit

@main
struct GamepadLensApp: App {
    @State private var manager = ControllerManager()

    init() {
        // SPM executable 需要手动激活为正常窗口应用（菜单栏 + 前台激活）
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(manager: manager)
        }
        .defaultSize(width: 1000, height: 650)
    }
}
