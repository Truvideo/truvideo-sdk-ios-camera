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
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/76.7.11-BETA.276/TruvideoSdkCamera.xcframework.zip",
            checksum: "223b4434ef0e06af5a2a1537477462a803bc48548dc835f59b96bf67720e8652"
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
