// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BLog",
    products: [
        .library(
            name: "BLog",
            targets: ["BLog"]),
        .library(
            name: "BLogMock",
            targets: ["BLogMock"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BLog",
            dependencies: []),
        .target(
            name: "BLogMock",
            dependencies: ["BLog"]),
        .testTarget(
            name: "BLogTests",
            dependencies: ["BLog", "BLogMock"]),
    ]
)
