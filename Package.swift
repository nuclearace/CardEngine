// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TheBuilders",
    products: [
        .executable(name: "Runner", targets: ["Runner"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "Runner", dependencies: ["Kit", "Games"]),
        .target(name: "Kit"),
        .target(name: "Games", dependencies: ["Kit"])
    ]
)
