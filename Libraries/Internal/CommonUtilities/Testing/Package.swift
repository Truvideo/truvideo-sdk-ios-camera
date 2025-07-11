// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonUtilitiesTesting",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CommonUtilitiesTesting",
            targets: ["CommonUtilitiesTesting"]
        ),
    ],
    targets: [
        .target(
                name: "TruvideoSdkFoundationTesting",
                dependencies: [
                    "TruvideoSdkFoundation"
                ],
                path: "Testing"
            ),
    ]
)