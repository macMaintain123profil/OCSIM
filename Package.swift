// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OSIM",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "OSIM",
            targets: ["OSIM"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OSIM",
            dependencies: [],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)