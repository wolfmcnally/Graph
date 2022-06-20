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
    ],
    targets: [
        .target(
            name: "WolfGraph",
            dependencies: []),
        .testTarget(
            name: "WolfGraphTests",
            dependencies: ["WolfGraph"]),
    ]
)
