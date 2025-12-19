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
        url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/79.0.0-BETA.1/TruvideoSdkCamera.xcframework.zip",
        checksum: "0aece8ca179f6a7545dd41ddfe2e7f99ba2574cd0ee6508a313adf1673ca2b43"
      ),
      .target(
        name: "TruvideoSdkCameraTargets",
        dependencies: [
          .target(name: "TruvideoSdkCamera")
        ],
        path: "Sources")
    ]
  )
  
