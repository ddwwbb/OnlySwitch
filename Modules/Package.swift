// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Extensions",
            targets: ["Extensions"]),
        .library(
            name: "Defines",
            targets: ["Defines"]),
        .library(
            name: "Switches",
            targets: ["Switches"]
        ),
        .library(
            name: "Utilities",
            targets: ["Utilities"]
        ),
        .library(
            name: "OnlyControl",
            targets: ["OnlyControl"]
        ),
        .library(
            name: "Reorderable",
            targets: ["Reorderable"]
        ),
        .library(
            name: "Design",
            targets: ["Design"]
        ),
        .library(
            name: "Networking",
            targets: ["Networking"]
        ),
        .library(
            name: "PureColorView",
            targets: ["PureColorView"]
        ),
        .library(
            name: "StickerView",
            targets: ["StickerView"]
        ),
        .library(
            name: "Authenticator",
            targets: ["Authenticator"]
        ),
        .library(
            name: "DesktopPet",
            targets: ["DesktopPet"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.26.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", exact: "2.8.1"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", exact: "2.3.1"),
        .package(url: "https://github.com/Alamofire/Alamofire", exact: "5.5.0"),
    ],
    targets: [
        .target(
            name: "Extensions",
            dependencies: [
                "Defines"
            ]),
        .target(
            name: "Defines"
        ),
        .target(
            name: "Switches",
            dependencies: [
                "Extensions"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "Utilities",
            dependencies: [
                "Extensions",
                "Defines"
            ]
        ),
        .target(
            name: "OnlyControl",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Extensions",
                "Authenticator",
                "Defines",
                "Switches",
                "Utilities",
                "Reorderable"
            ]
        ),
        .target(name: "Reorderable"),
        .target(name: "Design"),
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .target(
            name: "PureColorView",
            dependencies: [
                "Extensions"
            ]
        ),
        .target(
            name: "StickerView",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Sharing", package: "swift-sharing"),
                "Defines",
                "Extensions"
            ]
        ),
        .target(
            name: "Authenticator",
            dependencies: [
                "Defines",
                "Extensions",
                "Utilities"
            ]
        ),
        .target(
            name: "DesktopPet"
        ),
        .testTarget(
            name: "ModulesTests",
            dependencies: [
                "Authenticator",
                "DesktopPet",
                "OnlyControl",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
