// swift-tools-version:5.8

  import PackageDescription
              
  let package = Package(
    name: "TruvideoSdkCamera",
    products: [
      .library(
        name: "TruvideoSdkCamera",
        targets: ["TruvideoSdkCameraTargets"])
    ],
    dependencies: [],
    targets: [
      .binaryTarget(
        name: "TruvideoSdkCamera",
        url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/78.2.0-BETA.9/TruvideoSdkCamera.xcframework.zip",
        checksum: "295a3ed8f0d5ff453a42e19f3e871c73e8f9afd68eb98e86ab459f2c72e8f84e"
      ),
      .target(
        name: "TruvideoSdkCameraTargets",
        dependencies: [
          .target(name: "TruvideoSdkCamera")
        ],
        path: "Sources")
    ]
  )
  
