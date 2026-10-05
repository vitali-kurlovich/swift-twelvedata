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
            name: "TwelveDataStream",
            targets: ["TwelveDataStream"]
        ),
        
            .library(
                name: "TwelveDataREST",
                targets: ["TwelveDataREST"]
            ),
    ],
    traits: [
        .trait(name: "TwelveDataStreamLogging", description: "Enables websocket logging features"),
        .trait(name: "TwelveDataRESTLogging", description: "Enables REST logging features"),
        .default(enabledTraits: ["TwelveDataStreamLogging", "TwelveDataRESTLogging"]),
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.15.1"),
        .package(url: "https://github.com/vitali-kurlovich/swift-io-stream", from: "0.1.5"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "TwelveDataStream",
            dependencies: [
                .product(
                    name: "StreamWebSocket",
                    package: "swift-io-stream"
                ),

                .product(
                    name: "Logging",
                    package: "swift-log",
                    condition: .when(traits: ["TwelveDataStreamLogging"])
                ),
            ]

        ),
        
            .target(
                name: "TwelveDataREST",
                dependencies: [
                    
                    .product(
                        name: "Logging",
                        package: "swift-log",
                        condition: .when(traits: ["TwelveDataRESTLogging"])
                    ),
                ]

            ),

        .testTarget(name: "TwelveDataTest", dependencies: [
            "TwelveDataREST",
        ]),
    ],
    swiftLanguageModes: [.v6]
)
