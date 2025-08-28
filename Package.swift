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
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/78.1.1-BETA.313/TruvideoSdkCamera.xcframework.zip",
            checksum: "e23064377d9b92a49a7cf32286a94776c680d07e7bfa9c7cf41d2c14a0afca6c"
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
