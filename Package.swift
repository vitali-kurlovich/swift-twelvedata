// swift-tools-version:6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-twelvedata",

    platforms: [
        .macOS(.v14),
        .iOS(.v16),
        .watchOS(.v10),
        .tvOS(.v17),
    ],

    products: [
        .library(
            name: "TwelveData",
            targets: ["TwelveData"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/vitali-kurlovich/swift-io-stream", from: "0.0.3"),

    ],
    targets: [
        .target(
            name: "TwelveData",
            dependencies: [
                .product(
                    name: "StreamWebSocket",
                    package: "swift-io-stream"
                ),
            ]

        ),
    ],
    swiftLanguageModes: [.v6]
)
