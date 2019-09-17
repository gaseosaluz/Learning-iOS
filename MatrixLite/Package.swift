// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MatrixLite",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .tvOS(.v11),
    ],
    products: [
        .library(
            name: "MatrixLite",
            targets: ["MatrixLite"]
        ),
    ],
    targets: [
        .target(
            name: "MatrixLite",
            dependencies: []
        ),
        .testTarget(
            name: "MatrixLiteTests",
            dependencies: ["MatrixLite"]
        ),
    ]
)
