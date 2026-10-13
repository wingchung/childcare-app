// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NestlingLocal",
    platforms: [.macOS(.v14)],
    products: [.library(name: "NestlingCore", targets: ["NestlingCore"])],
    targets: [
        .target(name: "NestlingCore", path: "ios/Nestling/Domain"),
        .testTarget(name: "NestlingCoreTests", dependencies: ["NestlingCore"], path: "Tests/NestlingCoreTests")
    ]
)
