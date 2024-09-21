// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Graph",
    products: [
        .library(
            name: "Graph",
            targets: ["Graph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfBase.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/wolfmcnally/FUID.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/wolfmcnally/SwiftSortedCollections.git", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
    ],
    targets: [
        .target(
            name: "Graph",
            dependencies: [
                "WolfBase",
                .product(name: "SortedCollections", package: "SwiftSortedCollections"),
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
