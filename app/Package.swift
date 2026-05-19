// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UVBurnTimer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "UVBurnTimerCore", targets: ["UVBurnTimerCore"])
    ],
    targets: [
        .target(name: "UVBurnTimerCore"),
        .testTarget(
            name: "UVBurnTimerCoreTests",
            dependencies: ["UVBurnTimerCore"]
        )
    ]
)
