// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RequestBuilder",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "RequestBuilder",
            targets: ["RequestBuilder"]
        ),
    ],
    targets: [
        .target(
            name: "RequestBuilder",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "RequestBuilderTests",
            dependencies: ["RequestBuilder"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
