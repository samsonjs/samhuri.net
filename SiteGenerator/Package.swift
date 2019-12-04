// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SiteGenerator",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"),
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0"),
    ],
    targets: [
        .target( name: "SiteGenerator", dependencies: [
            "Ink",
            "Stencil",
        ]),
        .testTarget(name: "SiteGeneratorTests", dependencies: ["SiteGenerator"]),
    ]
)
