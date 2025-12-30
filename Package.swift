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
        url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/78.3.1-BETA.1/TruvideoSdkCamera.xcframework.zip",
        checksum: "4aa59442abedd66c15a19beb68e03d3853f3bd21bde7e58295222f86bfcfa390"
      ),
      .target(
        name: "TruvideoSdkCameraTargets",
        dependencies: [
          .target(name: "TruvideoSdkCamera")
        ],
        path: "Sources")
    ]
  )
  
