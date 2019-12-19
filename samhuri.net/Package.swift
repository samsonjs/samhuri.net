// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "samhuri.net",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "samhuri.net",
            targets: ["samhuri.net"]),
    ],
    dependencies: [
        .package(path: "../SiteGenerator"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"),
        .package(url: "https://github.com/johnsundell/plot.git", from: "0.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "samhuri.net",
            dependencies: [
                "Plot",
                "SiteGenerator",
                "Stencil",
        ]),
        .testTarget(
            name: "samhuri.netTests",
            dependencies: ["samhuri.net"]),
    ]
)
