import Foundation
import GameController
import Observation

/// 手柄连接管理与输入状态
@Observable
@MainActor
final class ControllerManager {

    // MARK: - 连接状态

    /// 已连接的控制器列表
    var controllers: [GCController] = []
    /// 当前选中的控制器
    var selectedController: GCController?

    // MARK: - 按键状态（可视化面板用）

    var buttonA: Float = 0
    var buttonB: Float = 0
    var buttonX: Float = 0
    var buttonY: Float = 0

    var dpadUp: Float = 0
    var dpadDown: Float = 0
    var dpadLeft: Float = 0
    var dpadRight: Float = 0

    var leftShoulder: Float = 0
    var rightShoulder: Float = 0
    var leftTrigger: Float = 0
    var rightTrigger: Float = 0

    var leftThumbstickX: Float = 0
    var leftThumbstickY: Float = 0
    var leftThumbstickButton: Float = 0

    var rightThumbstickX: Float = 0
    var rightThumbstickY: Float = 0
    var rightThumbstickButton: Float = 0

    var buttonMenu: Float = 0
    var buttonOptions: Float = 0
    var buttonHome: Float = 0

    // MARK: - 技术数据面板

    /// 最近触发的按键名称
    var lastElementName: String = "—"
    /// 最近按键的压力值
    var lastValue: Float = 0
    /// 最近按键是否处于按下状态
    var lastIsPressed: Bool = false
    /// 最近事件的时间戳
    var lastTimestamp: Date?

    // MARK: - 运动数据

    var gravityX: Double = 0
    var gravityY: Double = 0
    var gravityZ: Double = 0
    var userAccelX: Double = 0
    var userAccelY: Double = 0
    var userAccelZ: Double = 0
    var rotationRateX: Double = 0
    var rotationRateY: Double = 0
    var rotationRateZ: Double = 0
    var hasMotion: Bool = false

    // MARK: - 事件日志

    var eventLog: [InputEvent] = []
    private let maxLogCount = 500

    // MARK: - 初始化

    init() {
        setupNotifications()
        refreshControllers()
    }

    // MARK: - 连接管理

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshControllers()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshControllers()
            }
        }
    }

    private func refreshControllers() {
        controllers = GCController.controllers()
        // 如果当前选中的控制器已断开，自动切换
        if let selected = selectedController, !controllers.contains(selected) {
            selectedController = controllers.first
        }
        if selectedController == nil {
            selectedController = controllers.first
        }
        // 为当前控制器注册输入监听
        if let controller = selectedController {
            registerInputHandlers(for: controller)
        }
    }

    /// 切换当前查看的控制器
    func selectController(_ controller: GCController) {
        selectedController = controller
        resetState()
        registerInputHandlers(for: controller)
    }

    // MARK: - 输入监听

    private func registerInputHandlers(for controller: GCController) {
        // 设置回调队列为主队列，确保 @MainActor 安全
        controller.handlerQueue = DispatchQueue.main

        guard let gamepad = controller.extendedGamepad else { return }

        gamepad.valueChangedHandler = { [weak self] gamepad, element in
            guard let self else { return }
            self.updateState(from: gamepad, changedElement: element)
        }

        // 运动数据
        if let motion = controller.motion {
            motion.valueChangedHandler = { [weak self] motion in
                guard let self else { return }
                self.updateMotion(from: motion)
            }
            hasMotion = true
        } else {
            hasMotion = false
        }
    }

    private func updateState(from gamepad: GCExtendedGamepad, changedElement: GCControllerElement) {
        // 更新所有按键状态
        buttonA = gamepad.buttonA.value
        buttonB = gamepad.buttonB.value
        buttonX = gamepad.buttonX.value
        buttonY = gamepad.buttonY.value

        dpadUp = gamepad.dpad.up.value
        dpadDown = gamepad.dpad.down.value
        dpadLeft = gamepad.dpad.left.value
        dpadRight = gamepad.dpad.right.value

        leftShoulder = gamepad.leftShoulder.value
        rightShoulder = gamepad.rightShoulder.value
        leftTrigger = gamepad.leftTrigger.value
        rightTrigger = gamepad.rightTrigger.value

        leftThumbstickX = gamepad.leftThumbstick.xAxis.value
        leftThumbstickY = gamepad.leftThumbstick.yAxis.value
        rightThumbstickX = gamepad.rightThumbstick.xAxis.value
        rightThumbstickY = gamepad.rightThumbstick.yAxis.value

        if let l3 = gamepad.buttonOptions {
            buttonOptions = l3.value
        }
        if let home = gamepad.buttonHome {
            buttonHome = home.value
        }
        buttonMenu = gamepad.buttonMenu.value

        if let l3 = gamepad.leftThumbstickButton {
            leftThumbstickButton = l3.value
        }
        if let r3 = gamepad.rightThumbstickButton {
            rightThumbstickButton = r3.value
        }

        // 识别变化的元素名称与值
        let (name, value, pressed) = identifyElement(changedElement, gamepad: gamepad)

        lastElementName = name
        lastValue = value
        lastIsPressed = pressed
        lastTimestamp = Date()

        // 记录事件日志
        let event = InputEvent(
            timestamp: Date(),
            elementName: name,
            value: value,
            isPressed: pressed
        )
        eventLog.append(event)
        if eventLog.count > maxLogCount {
            eventLog.removeFirst(eventLog.count - maxLogCount)
        }
    }

    private func updateMotion(from motion: GCMotion) {
        gravityX = motion.gravity.x
        gravityY = motion.gravity.y
        gravityZ = motion.gravity.z
        userAccelX = motion.userAcceleration.x
        userAccelY = motion.userAcceleration.y
        userAccelZ = motion.userAcceleration.z
        rotationRateX = motion.rotationRate.x
        rotationRateY = motion.rotationRate.y
        rotationRateZ = motion.rotationRate.z
    }

    // MARK: - 元素识别

    private func identifyElement(
        _ element: GCControllerElement,
        gamepad: GCExtendedGamepad
    ) -> (name: String, value: Float, isPressed: Bool) {
        switch element {
        case gamepad.buttonA:
            return ("A", gamepad.buttonA.value, gamepad.buttonA.isPressed)
        case gamepad.buttonB:
            return ("B", gamepad.buttonB.value, gamepad.buttonB.isPressed)
        case gamepad.buttonX:
            return ("X", gamepad.buttonX.value, gamepad.buttonX.isPressed)
        case gamepad.buttonY:
            return ("Y", gamepad.buttonY.value, gamepad.buttonY.isPressed)
        case gamepad.dpad:
            let dir = dpadDirection(gamepad.dpad)
            let maxVal = max(gamepad.dpad.up.value, gamepad.dpad.down.value,
                            gamepad.dpad.left.value, gamepad.dpad.right.value)
            return ("D-pad \(dir)", maxVal, maxVal > 0)
        case gamepad.leftShoulder:
            return ("L1", gamepad.leftShoulder.value, gamepad.leftShoulder.isPressed)
        case gamepad.rightShoulder:
            return ("R1", gamepad.rightShoulder.value, gamepad.rightShoulder.isPressed)
        case gamepad.leftTrigger:
            return ("L2", gamepad.leftTrigger.value, gamepad.leftTrigger.isPressed)
        case gamepad.rightTrigger:
            return ("R2", gamepad.rightTrigger.value, gamepad.rightTrigger.isPressed)
        case gamepad.leftThumbstick:
            let x = gamepad.leftThumbstick.xAxis.value
            let y = gamepad.leftThumbstick.yAxis.value
            return ("L-Stick", max(abs(x), abs(y)), abs(x) > 0.1 || abs(y) > 0.1)
        case gamepad.rightThumbstick:
            let x = gamepad.rightThumbstick.xAxis.value
            let y = gamepad.rightThumbstick.yAxis.value
            return ("R-Stick", max(abs(x), abs(y)), abs(x) > 0.1 || abs(y) > 0.1)
        case gamepad.buttonMenu:
            return ("Menu", gamepad.buttonMenu.value, gamepad.buttonMenu.isPressed)
        default:
            if let opt = gamepad.buttonOptions, element === opt {
                return ("Options", opt.value, opt.isPressed)
            }
            if let home = gamepad.buttonHome, element === home {
                return ("Home", home.value, home.isPressed)
            }
            if let l3 = gamepad.leftThumbstickButton, element === l3 {
                return ("L3", l3.value, l3.isPressed)
            }
            if let r3 = gamepad.rightThumbstickButton, element === r3 {
                return ("R3", r3.value, r3.isPressed)
            }
            return ("Unknown", 0, false)
        }
    }

    private func dpadDirection(_ dpad: GCControllerDirectionPad) -> String {
        var parts: [String] = []
        if dpad.up.isPressed { parts.append("↑") }
        if dpad.down.isPressed { parts.append("↓") }
        if dpad.left.isPressed { parts.append("←") }
        if dpad.right.isPressed { parts.append("→") }
        return parts.isEmpty ? "—" : parts.joined()
    }

    // MARK: - 工具方法

    func clearLog() {
        eventLog.removeAll()
    }

    private func resetState() {
        buttonA = 0; buttonB = 0; buttonX = 0; buttonY = 0
        dpadUp = 0; dpadDown = 0; dpadLeft = 0; dpadRight = 0
        leftShoulder = 0; rightShoulder = 0
        leftTrigger = 0; rightTrigger = 0
        leftThumbstickX = 0; leftThumbstickY = 0; leftThumbstickButton = 0
        rightThumbstickX = 0; rightThumbstickY = 0; rightThumbstickButton = 0
        buttonMenu = 0; buttonOptions = 0; buttonHome = 0
        lastElementName = "—"; lastValue = 0; lastIsPressed = false; lastTimestamp = nil
        gravityX = 0; gravityY = 0; gravityZ = 0
        userAccelX = 0; userAccelY = 0; userAccelZ = 0
        rotationRateX = 0; rotationRateY = 0; rotationRateZ = 0
        hasMotion = false
    }
}
