// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Graph",
    products: [
        .library(
            name: "Graph",
            targets: ["Graph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfBase.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/wolfmcnally/FUID.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/wolfmcnally/swift-collections", .upToNextMajor(from: "1.1.0")),
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
                "FUID",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
    ]
)
