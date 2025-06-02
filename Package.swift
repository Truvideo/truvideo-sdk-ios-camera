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
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/76.7.2-BETA.192/TruvideoSdkCamera.xcframework.zip",
            checksum: "a65c39cfe6cd156b67eca95557727eff680f8acfa50386d73a76ac763ca792a8"
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
