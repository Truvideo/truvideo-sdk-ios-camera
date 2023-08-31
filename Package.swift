// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageVersion = "0.0.3"

let package = Package(
    name: "TruvideoSdkCamera",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TruvideoSdkCamera",
            targets: ["TruvideoSdkCamera"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "TruvideoSdkCamera",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/\(packageVersion)/TruvideoSdkCamera.xcframework.zip",
            checksum: "9af5cf976ac115bfb4326501045fdfdcbcfe4d259dd21028b77009f41d2d3214"
        ),
    ]
)
