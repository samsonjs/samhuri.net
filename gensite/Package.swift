// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gensite",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    dependencies: [
        .package(path: "../samhuri.net"),
    ],
    targets: [
        .target( name: "gensite", dependencies: [
            "samhuri.net",
        ]),
        .testTarget(name: "gensiteTests", dependencies: ["gensite"]),
    ]
)
