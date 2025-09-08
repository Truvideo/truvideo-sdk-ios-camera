# Using the AR Camera

Learn how to integrate the AR Camera in **TruvideoSdkCamera** to enable Augmented Reality (AR) experiences, including 3D
object placement, distance measurement, and AR-enhanced video recording.

## Overview

The **TruvideoSdkCamera** framework provides a customizable AR Camera that allows applications to:

- 📍 **Place 3D objects** in real-world space
- 📏 **Measure distances** using a **virtual ruler**
- 🎥 **Capture AR-enhanced videos**
- 🔄 **Switch between front and rear cameras**
- 💡 **Enable or disable flash**

 This guide explains how to configure and integrate the AR Camera using **TruvideoSdkCamera**.

## Pre-Requisites

 Before using the camera, ensure the necessary frameworks are imported and the user is **authenticated**.

### Import Required Modules

To access AR functionalities, import the following frameworks:

- **TruvideoSdk**
- **TruvideoCameraSdk**

## Configuring the Camera

To configure the AR Camera, create a ``TruvideoSdkCameraConfiguration`` object with your desired settings.

<!-- AR-Camera-Configuration-Creation -->
```swift
let cameraConfig = TruvideoSdkCameraConfiguration(
    flashMode: .auto,
    mode: .videoAndPicture(videoMaxCount: 5, pictureMaxCount: 3, durationLimit: 10),
    orientation: .portrait
)
```
<!-- end AR-Camera-Configuration-Creation -->

## Integrating the AR Camera in SwiftUI

The AR Camera can be embedded in a SwiftUI view using the presentTruvideoSdkARCameraView modifier. This allows users to
interact with AR objects and capture AR-enhanced photos and videos.

To present the AR Camera, bind a Boolean state to control visibility and pass in an AR Camera configuration preset.

<!-- SwiftUI-AR-Camera-Integration -->
```swift
    var body: some View {
        VStack(spacing: 16) {
            Button("Open AR Camera") {
                showARCamera = true
            }
        }
        .presentTruvideoSdkARCameraView(isPresented: showARCamera, preset: cameraPreset) { result in
            print(result)
        }
    }
```
<!-- end SwiftUI-AR-Camera-Integration -->

## Handling Camera Output

When a user captures a photo or records a video, the `onComplete` closure provides a ``TruvideoSdkCameraResult`` object.
This result contains one or more AR-enhanced media files, including metadata such as file path and type.

To handle the camera output, process the result in the `onComplete` closure.

 ```swift
 func processCameraResult(_ result: TruvideoSdkCameraResult) {
     for media in result.media {
         print("Captured media: \(media.filePath)")
     }
 }
```

## Summary

 - Use **presentTruvideoSdkARCameraView** to integrate the AR Camera in SwiftUI.
 - Control visibility using a **Boolean state**.
 - Pass a **camera preset** to configure capture settings.
 - Handle captured media using the **onComplete** callback.

 ## See Also

- <doc:GettingStartedWithCamera>
- <doc:UsingCameraScanner>
