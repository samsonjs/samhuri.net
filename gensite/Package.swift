// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gensite",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    dependencies: [
        .package(path: "../samhuri.net"),
    ],
    targets: [
        .executableTarget( name: "gensite", dependencies: [
            "samhuri.net",
        ]),
        .testTarget(name: "gensiteTests", dependencies: ["gensite"]),
    ]
)
