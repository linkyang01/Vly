// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Vly",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Vly",
            targets: ["Vly"])
    ],
    dependencies: [
        .package(url: "https://github.com/kingslay/KSPlayer.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Vly",
            dependencies: [
                .product(name: "KSPlayer", package: "KSPlayer")
            ]),
        .testTarget(
            name: "VlyTests",
            dependencies: ["Vly"])
    ]
)
