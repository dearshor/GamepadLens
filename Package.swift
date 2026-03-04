// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GamepadLens",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "GamepadLens",
            path: "Sources/GamepadLens"
        )
    ]
)
