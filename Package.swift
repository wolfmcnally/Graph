// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Graph",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "Graph",
            targets: ["Graph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfBase.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/apple/swift-collections", branch: "main"),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "Graph",
            dependencies: [
                "WolfBase",
                .product(name: "Collections", package: "swift-collections"),
            ]),
        .testTarget(
            name: "GraphTests",
            dependencies: [
                "Graph",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
    ]
)
