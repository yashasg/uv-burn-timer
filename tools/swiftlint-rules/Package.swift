// swift-tools-version: 6.0
import PackageDescription

// SwiftSyntax-based custom HIG lint rules — ADR-0003 spike.
//
// This package is intentionally separate from the iOS app's SPM tree
// (app/Package.swift). The iOS target does not need to link swift-syntax;
// only the lint tooling does. Lint output is consumed via the
// `swiftlint-ast` CLI emitting SwiftLint-compatible diagnostics, or via
// in-process unit tests against source-string fixtures.

let package = Package(
    name: "SwiftLintASTRules",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SwiftLintASTRules", targets: ["SwiftLintASTRules"]),
        .executable(name: "swiftlint-ast", targets: ["swiftlint-ast"])
    ],
    dependencies: [
        // WI-loop30-2-spike-pin-fix: pin to a public swift-syntax release tag
        // matching the toolchain (swift-6.3.2-RELEASE was the closest stable
        // release to the swift-6.3-DEVELOPMENT-SNAPSHOT-2026-05-19-a checkout
        // used during the spike — see ADR-0003 §Spike result). The earlier
        // `.package(path: …DerivedData…)` pin was a local-machine hack that
        // would break CI; this URL pin restores reproducibility.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "603.0.1")
    ],
    targets: [
        .target(
            name: "SwiftLintASTRules",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .executableTarget(
            name: "swiftlint-ast",
            dependencies: ["SwiftLintASTRules"]
        ),
        .testTarget(
            name: "SwiftLintASTRulesTests",
            dependencies: ["SwiftLintASTRules"]
        )
    ]
)
