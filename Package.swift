// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "TruvideoSdkCamera",
    products: [
        .library(
            name: "TruvideoSdkCamera",
            targets: ["TruvideoSdkCameraTargets"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "TruvideoSdkCamera",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/78.1.2/TruvideoSdkCamera.xcframework.zip",
            checksum: "2494f6e7d02b033cbff16dd3ae73f9643150d361a58ff58c70d41a9d411c1923"
        ),
        .target(
            name: "TruvideoSdkCameraTargets",
            dependencies: [
                .target(name: "TruvideoSdkCamera")
            ],
            path: "Sources"
        )
    ]
)
