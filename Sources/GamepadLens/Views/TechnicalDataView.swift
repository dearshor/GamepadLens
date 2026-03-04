import SwiftUI

/// 技术数据实时显示面板
struct TechnicalDataView: View {
    var manager: ControllerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("技术数据")
                .font(.headline)
                .padding(.bottom, 8)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                dataRow("按键名称", manager.lastElementName)
                dataRow("压力值 (value)", String(format: "%.4f", manager.lastValue))
                dataRow("按下状态 (isPressed)", manager.lastIsPressed ? "true ●" : "false ○")
                dataRow("时间戳", timestampText)

                Divider().gridCellUnsizedAxes(.horizontal)

                dataRow("左摇杆 X", String(format: "%+.4f", manager.leftThumbstickX))
                dataRow("左摇杆 Y", String(format: "%+.4f", manager.leftThumbstickY))
                dataRow("右摇杆 X", String(format: "%+.4f", manager.rightThumbstickX))
                dataRow("右摇杆 Y", String(format: "%+.4f", manager.rightThumbstickY))

                Divider().gridCellUnsizedAxes(.horizontal)

                dataRow("左扳机 (L2)", String(format: "%.4f", manager.leftTrigger))
                dataRow("右扳机 (R2)", String(format: "%.4f", manager.rightTrigger))
            }

            if manager.hasMotion {
                Divider().padding(.vertical, 6)
                Text("运动传感器")
                    .font(.subheadline.bold())
                    .padding(.bottom, 4)
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 4) {
                    dataRow("重力 X/Y/Z", formatVec3(manager.gravityX, manager.gravityY, manager.gravityZ))
                    dataRow("加速度 X/Y/Z", formatVec3(manager.userAccelX, manager.userAccelY, manager.userAccelZ))
                    dataRow("角速度 X/Y/Z", formatVec3(manager.rotationRateX, manager.rotationRateY, manager.rotationRateZ))
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 辅助

    private var timestampText: String {
        guard let ts = manager.lastTimestamp else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: ts)
    }

    @ViewBuilder
    private func dataRow(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .trailing)
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }

    private func formatVec3(_ x: Double, _ y: Double, _ z: Double) -> String {
        String(format: "%+.3f, %+.3f, %+.3f", x, y, z)
    }
}
