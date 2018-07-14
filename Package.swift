// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let games: [Target.Dependency] = ["TheBuilders", "TicTacToe"]

let package = Package(
    name: "CardEngine",
    products: [
        .executable(name: "Runner", targets: ["Runner"]),
        .executable(name: "Server", targets: ["Server"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "Runner", dependencies: ["Kit", "NIO"] + games),
        .target(name: "Kit", dependencies: ["NIO"]),

        // Server targets
        .target(name: "ServerApp", dependencies: ["Vapor"] + games, path: "Sources/Server/App"),
        .target(name: "Server", dependencies: ["ServerApp", "Vapor"], path: "Sources/Server/Run"),

        // Game modules go here
        .target(name: "TheBuilders", dependencies: ["Kit", "NIO"], path: "Sources/Games/TheBuilders"),
        .target(name: "TicTacToe", dependencies: ["Kit", "NIO"], path: "Sources/Games/TicTacToe"),
    ]
)
