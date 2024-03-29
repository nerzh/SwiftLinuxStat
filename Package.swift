// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLinuxStat",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftLinuxStat",
            targets: ["SwiftLinuxStat"]),
    ],
    dependencies: [
        .package(name: "FileUtils", url: "https://github.com/nerzh/SwiftFileUtils.git", from: "1.1.0"),
        .package(name: "SwiftExtensionsPack", url: "https://github.com/nerzh/swift-extensions-pack.git", from: "1.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftLinuxStat",
            dependencies: [
                .product(name: "FileUtils", package: "FileUtils"),
                .product(name: "SwiftExtensionsPack", package: "SwiftExtensionsPack"),
            ]),
        .testTarget(
            name: "SwiftLinuxStatTests",
            dependencies: ["SwiftLinuxStat"]),
    ]
)
