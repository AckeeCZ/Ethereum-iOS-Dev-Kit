// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContractCodegen",
    products: [
        .library(name: "ContractCodegen", targets: ["ContractCodegenFramework"]),
        .executable(name: "contractgen", targets: ["contractgen"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jakeheis/SwiftCLI", .upToNextMinor(from: "5.2.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.1")),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit", .upToNextMinor(from: "2.6.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ContractCodegenFramework",
            dependencies: [
                "PathKit",
                "StencilSwiftKit",
            ]),
        .target(
            name: "contractgen",
            dependencies: [
                "SwiftCLI",
                .target(name: "ContractCodegenFramework")
            ]),
        .testTarget(
            name: "CLICodegenTests",
            dependencies: [
                .target(name: "ContractCodegenFramework"),
                "SwiftCLI",
                "PathKit",
            ]),
    ]
)
