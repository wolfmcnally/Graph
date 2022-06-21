// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "WolfGraph",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "WolfGraph",
            targets: ["WolfGraph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfBase.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "WolfGraph",
            dependencies: ["WolfBase"]),
        .testTarget(
            name: "WolfGraphTests",
            dependencies: ["WolfGraph"]),
    ]
)
