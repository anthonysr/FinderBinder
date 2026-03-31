// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FinderBinder",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "FinderBinder",
            path: "FinderBinder",
            exclude: ["Info.plist"]
        )
    ]
)
