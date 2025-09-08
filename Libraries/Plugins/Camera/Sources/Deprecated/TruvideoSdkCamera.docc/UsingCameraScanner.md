# Using the Camera Scanner

Learn how to integrate the Camera Scanner in **TruvideoSdkCamera** to enable barcode and QR code
scanning with flash support, auto-close functionality, and validation capabilities.

## Overview

The Scanner Camera in **TruvideoSdkCamera** provides a fast and efficient way to scan various barcode 
formats. It allows applications to:

- 📡 **Scan barcodes** (Code-39, Code-93)
- 🏷️ **Read QR Codes** for mobile interactions
- 📋 **Detect DataMatrix codes** for logistics and inventory management
- 🔦 **Enable or disable flash** for scanning in low-light conditions
- ✅ **Perform automatic validation** before accepting a scan
- 🔄 **Auto-close the scanner** after a successful scan

 This guide explains how to configure and integrate the Camera using **TruvideoSdkCamera**.

## Pre-Requisites

Before using the camera, ensure the necessary frameworks are imported and the user is 
**authenticated**.

### Import Required Modules

To access camera functionalities, import the following frameworks:

- **TruvideoSdk**
- **TruvideoCameraSdk**

## Configuring the Camera

To configure the **Scanner Camera**, create a ``TruvideoSdkScannerCameraConfiguration`` object with
your desired settings.

<!-- Scanner-Camera-Configuration-Creation -->
```swift
    let cameraPreset = TruvideoSdkScannerCameraConfiguration(
        flashMode: .auto,
        orientation: .portrait,
        codeFormats: [.code39, .codeQR],
        validator: { scannedCode in
            return scannedCode.hasPrefix("VALID-")
        },
        autoClose: true
    )
```
<!-- end Scanner-Camera-Configuration-Creation -->

## Integrating the Camera Scanner in SwiftUI

The Camera Scanner can be embedded in a SwiftUI view using the **presentTruvideoSdkScannerCameraView** 
modifier. This allows users to scan barcodes and QR codes directly within a SwiftUI-based application.

To present the camera scanner, bind a **Boolean state** to control visibility and pass in a camera configuration preset.

<!-- SwiftUI-Scanner-Camera-Integration -->
```swift
    var body: some View {
        VStack(spacing: 16) {
            Button("Open Scanner") {
                showScanner = true
            }
        }
        .presentTruvideoSdkScannerCameraView(isPresented: $showScanner, preset: cameraPreset) { result in
            print(result)
        }
    }
```
