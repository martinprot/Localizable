// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Localizable",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),
		// 🌿 A front-end framework for Vapor
		.package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

