import SwiftUI
import GameController

/// 顶部控制器连接状态栏
struct ControllerInfoView: View {
    @Bindable var manager: ControllerManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: manager.controllers.isEmpty ? "gamecontroller" : "gamecontroller.fill")
                .font(.title2)
                .foregroundStyle(manager.controllers.isEmpty ? Color.secondary : Color.green)

            if manager.controllers.isEmpty {
                Text("未检测到手柄，请连接手柄（蓝牙或 USB）")
                    .foregroundStyle(.secondary)
            } else {
                Picker("控制器", selection: Binding(
                    get: { manager.selectedController },
                    set: { controller in
                        if let controller { manager.selectController(controller) }
                    }
                )) {
                    ForEach(Array(manager.controllers.enumerated()), id: \.offset) { index, controller in
                        Text(controllerLabel(controller, index: index))
                            .tag(Optional(controller))
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 300)
            }

            Spacer()

            if let controller = manager.selectedController {
                HStack(spacing: 16) {
                    if let vendor = controller.vendorName {
                        Label(vendor, systemImage: "building.2")
                    }
                    Label(controller.productCategory, systemImage: "tag")
                    if let battery = controller.battery {
                        BatteryView(battery: battery)
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func controllerLabel(_ controller: GCController, index: Int) -> String {
        let name = controller.vendorName ?? controller.productCategory
        return "P\(index + 1): \(name)"
    }
}

/// 电池状态指示
struct BatteryView: View {
    let battery: GCDeviceBattery

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIcon)
            Text("\(Int(battery.batteryLevel * 100))%")
        }
    }

    private var batteryIcon: String {
        switch battery.batteryState {
        case .charging:
            return "battery.100percent.bolt"
        case .full:
            return "battery.100percent"
        default:
            let level = battery.batteryLevel
            if level > 0.75 { return "battery.100percent" }
            if level > 0.5 { return "battery.75percent" }
            if level > 0.25 { return "battery.50percent" }
            return "battery.25percent"
        }
    }
}
