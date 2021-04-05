// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlfredWorkflowUpdater",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "AlfredWorkflowUpdater",
            targets: ["AlfredWorkflowUpdater"]
        ),
    ],
    dependencies: [
        .package(
            name: "SwiftSoup",
            url: "https://github.com/scinfu/SwiftSoup",
            from: "2.3.2"
        ),
    ],
    targets: [
        .target(
            name: "AlfredWorkflowUpdater",
            dependencies: ["SwiftSoup"]
        ),
        .testTarget(
            name: "AlfredWorkflowUpdaterTests",
            dependencies: ["AlfredWorkflowUpdater"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
