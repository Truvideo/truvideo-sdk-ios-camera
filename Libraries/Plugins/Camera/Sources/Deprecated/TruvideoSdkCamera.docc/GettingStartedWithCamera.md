# Integrating the Camera into Your App

Learn how to integrate the Camera in **TruvideoSdkCamera** for photo and video capturing.

## Overview

 The **TruvideoSdkCamera** framework provides a customizable Camera that allows applications to:

 - 📸 **Take high-resolution photos**
 - 🎥 **Record videos with configurable duration**
 - 🔄 **Switch between front and rear cameras**
 - 💡 **Enable or disable flash**
 - 📐 **Control camera orientation and resolution**

 This guide explains how to configure and integrate the Camera using **TruvideoSdkCamera**.

## Pre-Requisites

 Before using the camera, ensure the necessary frameworks are imported and the user is **authenticated**.

### Import Required Modules

To access camera functionalities, import the following frameworks:

- **TruvideoSdk**
- **TruvideoCameraSdk**

## Configuring the Camera

To configure the camera, create a ``TruvideoSdkCameraConfiguration`` object with your desired settings.

<!-- Camera-Configuration-Creation -->
```swift
    let cameraPreset = TruvideoSdkCameraConfiguration(
        flashMode: .auto,
        mode: .videoAndPicture(videoMaxCount: 5, pictureMaxCount: 3, durationLimit: 10),
        orientation: .portrait
    )
```
<!-- end Camera-Configuration-Creation -->

## Integrating the Camera in SwiftUI

The Standard Camera can be embedded in a SwiftUI view using the **presentTruvideoSdkCameraView** modifier. This allows users
to capture photos and videos directly within your SwiftUI-based application.

To present the camera, bind a **Boolean state** to control visibility and pass in a camera configuration preset.

<!-- SwiftUI-Camera-Integration -->
```swift
    var body: some View {
        VStack(spacing: 16) {
            Button("Open Camera") {
                $showCamera = true
            }
        }
        .presentTruvideoSdkCameraView(isPresented: $showCamera, preset: cameraPreset) { result in
            print(result)
        }
    }
```
<!-- end SwiftUI-Camera-Integration -->

## Handling Camera Output

When a user captures a photo or records a video, the `onComplete` closure provides a ``TruvideoSdkCameraResult`` object.
This result contains one or more media files, including metadata such as file path and type.

To handle the camera output, process the result in the `onComplete` closure.

 ```swift
 func processCameraResult(_ result: TruvideoSdkCameraResult) {
     for media in result.media {
         print("Captured media: \(media.filePath)")
     }
 }
```

## Summary

 - Use **presentTruvideoSdkCameraView** to **integrate the camera in SwiftUI**.
 - Control visibility using a **Boolean state**.
 - Pass a **camera preset** to configure capture settings.
 - Handle captured media using the **onComplete** callback.

 ## See Also

- <doc:UsingARCamera>
- <doc:UsingScannerCamera>
