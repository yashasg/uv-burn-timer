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
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.63.2")
    ],
    targets: [
        .target(
            name: "UVBurnTimerCore",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "UVBurnTimerCoreTests",
            dependencies: ["UVBurnTimerCore"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        )
    ]
)
