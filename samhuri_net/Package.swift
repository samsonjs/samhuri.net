// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "samhuri_net",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "samhuri_net",
            targets: ["samhuri_net"]),
    ],
    dependencies: [
        .package(path: "../SiteGenerator"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "samhuri_net",
            dependencies: [
                "SiteGenerator",
        ]),
        .testTarget(
            name: "samhuri_netTests",
            dependencies: ["samhuri_net"]),
    ]
)
