// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Studding",
    products: [
        .library(name: "Studding", targets: ["Studding"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KittyMac/Hitch.git", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "Studding",
            dependencies: [
                "Hitch"
            ]),
        .testTarget(
            name: "StuddingTests",
            dependencies: ["Studding"]),
    ]
)
