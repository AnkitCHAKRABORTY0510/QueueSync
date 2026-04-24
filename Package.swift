// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QueueSync",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "queuesync", targets: ["QueueSyncCLI"]),
        .executable(name: "QueueSyncApp", targets: ["QueueSyncApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "QueueSyncCore",
            dependencies: []),
        .executableTarget(
            name: "QueueSyncCLI",
            dependencies: ["QueueSyncCore"]),
        .executableTarget(
            name: "QueueSyncApp",
            dependencies: ["QueueSyncCore"],
            exclude: ["Info.plist", "QueueSyncApp.entitlements"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/QueueSyncApp/Info.plist",
                    "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__entitlements", "-Xlinker", "Sources/QueueSyncApp/QueueSyncApp.entitlements"
                ])
            ]),
        .testTarget(
            name: "QueueSyncTests",
            dependencies: ["QueueSyncCore"]),
    ]
)
