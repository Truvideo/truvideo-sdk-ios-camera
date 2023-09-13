// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonPackageVersion = "0.0.1"
let packageVersion = "0.0.7"
let sharedPackageVersion = "0.0.3"

let package = Package(
    name: "TruvideoSdkCamera",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TruvideoSdkCamera",
            targets: ["TruvideoSdkCameraTargets"]),
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
            url: "https://github.com/Truvideo/truvideo-sdk-ios-common-wrapper/releases/download/\(commonPackageVersion)/Common.xcframework.zip",
            checksum: "0d4b5f63a41b265a9522f8957785bdb04c355a325cb38a9bff760281e96d7d38"
        ),
        .binaryTarget(
            name: "Shared",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-common/releases/download/\(sharedPackageVersion)/shared.xcframework.zip",
            checksum: "5028e25b25b24e6f35fbe4484dfc438a31345a9d5bf5666640e99849cfb497cb"
        ),
        .binaryTarget(
            name: "TruvideoSdkCamera",
            url: "https://github.com/Truvideo/truvideo-sdk-ios-camera/releases/download/\(packageVersion)/TruvideoSdkCamera.xcframework.zip",
            checksum: "3d76fff01b86f4d1d660752e29236f585d2534443a0e5321b96ddfbea94a3d97"
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
