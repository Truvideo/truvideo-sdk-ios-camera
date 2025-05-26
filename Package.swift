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
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/76.6.1-BETA.171/TruvideoSdkCamera.xcframework.zip",
            checksum: "f30be7a62b3c74d53ce84234cf236248aedb9e3fdeeb83eab631cac75f25c91f"
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
