import SwiftUI

/// 手柄按键可视化面板
struct GamepadVisualizerView: View {
    var manager: ControllerManager

    var body: some View {
        VStack(spacing: 0) {
            Text("按键可视化")
                .font(.headline)
                .padding(.bottom, 8)

            if manager.selectedController == nil {
                ContentUnavailableView(
                    "未连接手柄",
                    systemImage: "gamecontroller",
                    description: Text("请通过蓝牙或 USB 连接手柄")
                )
            } else {
                gamepadLayout
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 手柄整体布局

    private var gamepadLayout: some View {
        VStack(spacing: 20) {
            // 上排：肩键 / 扳机键
            HStack(spacing: 60) {
                VStack(spacing: 4) {
                    TriggerBar(label: "L2", value: manager.leftTrigger)
                    ButtonCell(label: "L1", value: manager.leftShoulder)
                }
                VStack(spacing: 4) {
                    TriggerBar(label: "R2", value: manager.rightTrigger)
                    ButtonCell(label: "R1", value: manager.rightShoulder)
                }
            }

            // 中排：左摇杆 + 中间按键 + 右摇杆
            HStack(spacing: 30) {
                // 左摇杆
                VStack(spacing: 4) {
                    ThumbstickView(
                        label: "L-Stick",
                        x: manager.leftThumbstickX,
                        y: manager.leftThumbstickY,
                        buttonValue: manager.leftThumbstickButton
                    )
                    Text("L3")
                        .font(.caption2)
                        .foregroundStyle(manager.leftThumbstickButton > 0 ? .primary : .tertiary)
                }

                // 中间功能键
                VStack(spacing: 8) {
                    ButtonCell(label: "Menu", value: manager.buttonMenu, size: 36)
                    HStack(spacing: 8) {
                        ButtonCell(label: "Opt", value: manager.buttonOptions, size: 32)
                        ButtonCell(label: "Home", value: manager.buttonHome, size: 32)
                    }
                }

                // 右摇杆
                VStack(spacing: 4) {
                    ThumbstickView(
                        label: "R-Stick",
                        x: manager.rightThumbstickX,
                        y: manager.rightThumbstickY,
                        buttonValue: manager.rightThumbstickButton
                    )
                    Text("R3")
                        .font(.caption2)
                        .foregroundStyle(manager.rightThumbstickButton > 0 ? .primary : .tertiary)
                }
            }

            // 下排：方向键 + 面部按键
            HStack(spacing: 60) {
                DpadView(
                    up: manager.dpadUp,
                    down: manager.dpadDown,
                    left: manager.dpadLeft,
                    right: manager.dpadRight
                )
                FaceButtonsView(
                    a: manager.buttonA,
                    b: manager.buttonB,
                    x: manager.buttonX,
                    y: manager.buttonY
                )
            }
        }
    }
}

// MARK: - 子组件

/// 单个按键指示
struct ButtonCell: View {
    let label: String
    let value: Float
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(Double(value) * 0.8 + 0.05))
                .frame(width: size, height: size)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                .frame(width: size, height: size)
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(value > 0 ? .white : .secondary)
        }
    }
}

/// 扳机键竖条
struct TriggerBar: View {
    let label: String
    let value: Float

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 44, height: 40)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: 44, height: CGFloat(value) * 40)
            }
            Text(String(format: "%.2f", value))
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

/// 摇杆可视化
struct ThumbstickView: View {
    let label: String
    let x: Float
    let y: Float
    let buttonValue: Float
    private let radius: CGFloat = 50

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: radius * 2, height: radius * 2)
                // 十字线
                Path { path in
                    path.move(to: CGPoint(x: 0, y: radius))
                    path.addLine(to: CGPoint(x: radius * 2, y: radius))
                    path.move(to: CGPoint(x: radius, y: 0))
                    path.addLine(to: CGPoint(x: radius, y: radius * 2))
                }
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                .frame(width: radius * 2, height: radius * 2)
                // 摇杆位置
                Circle()
                    .fill(buttonValue > 0 ? Color.red : Color.accentColor)
                    .frame(width: 16, height: 16)
                    .offset(
                        x: CGFloat(x) * radius * 0.9,
                        y: CGFloat(-y) * radius * 0.9 // Y 轴取反
                    )
            }
            .frame(width: radius * 2, height: radius * 2)
            Text("(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

/// 方向键（D-pad）
struct DpadView: View {
    let up: Float, down: Float, left: Float, right: Float

    var body: some View {
        VStack(spacing: 2) {
            ButtonCell(label: "↑", value: up, size: 36)
            HStack(spacing: 2) {
                ButtonCell(label: "←", value: left, size: 36)
                Color.clear.frame(width: 36, height: 36)
                ButtonCell(label: "→", value: right, size: 36)
            }
            ButtonCell(label: "↓", value: down, size: 36)
        }
    }
}

/// 面部按键（A/B/X/Y 菱形排列）
struct FaceButtonsView: View {
    let a: Float, b: Float, x: Float, y: Float

    var body: some View {
        VStack(spacing: 2) {
            ButtonCell(label: "Y", value: y, size: 36)
            HStack(spacing: 2) {
                ButtonCell(label: "X", value: x, size: 36)
                Color.clear.frame(width: 36, height: 36)
                ButtonCell(label: "B", value: b, size: 36)
            }
            ButtonCell(label: "A", value: a, size: 36)
        }
    }
}
