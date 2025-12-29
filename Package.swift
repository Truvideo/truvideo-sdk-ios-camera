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
        url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/78.3.0-BETA.1/TruvideoSdkCamera.xcframework.zip",
        checksum: "fb465f5fb739a32517090a9ead5642daad4ff91b2cc54c30b83a27c7cdd1ab0b"
      ),
      .target(
        name: "TruvideoSdkCameraTargets",
        dependencies: [
          .target(name: "TruvideoSdkCamera")
        ],
        path: "Sources")
    ]
  )
  
