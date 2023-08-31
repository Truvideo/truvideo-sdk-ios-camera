// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonPackageVersion = "0.0.3"
let packageVersion = "0.0.5"

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
            name: "Common",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-common/releases/download/\(commonPackageVersion)/Common.xcframework.zip",
            checksum: "52c0e808ce21419edb3f0b6f2c9551821f8995caa975db0b901c6afad176610f"
        ),
        .binaryTarget(
            name: "TruvideoSdkCamera",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/\(packageVersion)/TruvideoSdkCamera.xcframework.zip",
            checksum: "a650414b97919c52bcb78b2683860db2ed3bd6b957f60cf828ecf7d7c57e338f"
        ),
        .target(
            name: "TruvideoSdkCameraTargets",
            dependencies: [
                .target(name: "Common"),
                .target(name: "TruvideoSdkCamera")
            ],
            path: "Sources"
        )
    ]
)
