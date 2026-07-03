// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mugshot",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "MugshotCore"),
        .executableTarget(name: "Mugshot", dependencies: ["MugshotCore"]),
        .testTarget(name: "MugshotCoreTests", dependencies: ["MugshotCore"]),
    ]
)
