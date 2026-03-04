import SwiftUI

/// 输入事件日志列表
struct EventLogView: View {
    var manager: ControllerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("事件日志")
                    .font(.headline)
                Spacer()
                Text("\(manager.eventLog.count) 条")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("清空") {
                    manager.clearLog()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.red)
            }
            .padding(.bottom, 6)

            if manager.eventLog.isEmpty {
                Text("暂无事件，请按手柄按键...")
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List(manager.eventLog) { event in
                        HStack(spacing: 8) {
                            Text(event.formattedTime)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 90, alignment: .leading)
                            Text(event.elementName)
                                .font(.caption.bold())
                                .frame(width: 60, alignment: .leading)
                            Text(String(format: "%.3f", event.value))
                                .font(.system(.caption, design: .monospaced))
                                .frame(width: 50, alignment: .trailing)
                            Circle()
                                .fill(event.isPressed ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Text(event.isPressed ? "按下" : "释放")
                                .font(.caption2)
                                .foregroundStyle(event.isPressed ? .primary : .secondary)
                        }
                        .id(event.id)
                    }
                    .listStyle(.plain)
                    .onChange(of: manager.eventLog.count) {
                        if let last = manager.eventLog.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
