import SwiftUI

/// 主界面布局
struct ContentView: View {
    var manager: ControllerManager

    var body: some View {
        VStack(spacing: 0) {
            // 顶部：控制器信息栏
            ControllerInfoView(manager: manager)
            Divider()

            // 主内容区
            HSplitView {
                // 左侧：可视化面板
                GamepadVisualizerView(manager: manager)
                    .frame(minWidth: 400)

                // 右侧：技术数据 + 事件日志
                VSplitView {
                    TechnicalDataView(manager: manager)
                        .frame(minHeight: 200)
                    EventLogView(manager: manager)
                        .frame(minHeight: 150)
                }
                .frame(minWidth: 350)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
