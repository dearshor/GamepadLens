import Foundation

/// 手柄输入事件记录
struct InputEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let elementName: String
    let value: Float
    let isPressed: Bool

    /// 格式化的时间戳字符串 (HH:mm:ss.SSS)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}
