// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_webrtc",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "flutter-webrtc", type: .static, targets: ["flutter_webrtc"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/webrtc-sdk/Specs", exact: "144.7559.04"),
    ],
    targets: [
        .target(
            name: "flutter_webrtc",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "WebRTC", package: "Specs"),
            ],
            resources: [
                // Add any resource files here if needed.
                // .process("PrivacyInfo.xcprivacy"),
            ],
            cxxSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Broadcast"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx14
)
