// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlfredWorkflowUpdater",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "AlfredWorkflowUpdater",
            targets: ["AlfredWorkflowUpdater"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/scinfu/SwiftSoup",
            from: "2.4.3"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "AlfredWorkflowUpdater",
            dependencies: ["AlfredWorkflowUpdaterCore"]
        ),
        .target(
            name: "AlfredWorkflowUpdaterCore",
            dependencies: ["SwiftSoup"]
        ),
        .testTarget(
            name: "AlfredWorkflowUpdaterCoreTests",
            dependencies: ["AlfredWorkflowUpdaterCore"],
            resources: [.process("Resources")]
        )
    ]
)
