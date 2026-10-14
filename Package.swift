// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MouseFix",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "mousefix", targets: ["MouseFix"]),
        .executable(name: "MouseFixApp", targets: ["MouseFixApp"]),
        .library(name: "MouseFixCore", targets: ["MouseFixCore"])
    ],
    targets: [
        .target(
            name: "MouseFixCore",
            dependencies: []
        ),
        .executableTarget(
            name: "MouseFix",
            dependencies: ["MouseFixCore"]
        ),
        .executableTarget(
            name: "MouseFixApp",
            dependencies: ["MouseFixCore"]
        ),
        .testTarget(
            name: "MouseFixTests",
            dependencies: ["MouseFixCore"]
        )
    ]
)
