// swift-tools-version:6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-twelvedata",

    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
        .tvOS(.v18),
    ],

    products: [
        .library(
            name: "TwelveData",
            targets: ["TwelveData"]
        ),
    ],
    traits: [
        .trait(name: "TwelveDataLogging", description: "Enables websocket logging features"),
        .default(enabledTraits: ["TwelveDataLogging"]),
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.15.1"),
        .package(url: "https://github.com/vitali-kurlovich/swift-io-stream", from: "0.1.5"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "TwelveData",
            dependencies: [
                .product(
                    name: "StreamWebSocket",
                    package: "swift-io-stream"
                ),

                .product(
                    name: "Logging",
                    package: "swift-log",
                    condition: .when(traits: ["TwelveDataLogging"])
                ),
            ]

        ),

        .testTarget(name: "TwelveDataTest", dependencies: [
            "TwelveData",
        ]),
    ],
    swiftLanguageModes: [.v6]
)
