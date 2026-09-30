// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "goat-or-sheep",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "GoatOrSheepKit"),
        .executableTarget(name: "GoatOrSheep", dependencies: ["GoatOrSheepKit"]),
        .executableTarget(name: "RenderScreenshots", dependencies: ["GoatOrSheepKit"]),
        .testTarget(name: "GoatOrSheepKitTests", dependencies: ["GoatOrSheepKit"]),
    ]
)
