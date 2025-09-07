//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension View {
    /// Presents a full-screen camera interface for media capture.
    ///
    /// This function creates and presents a camera view that allows users to capture
    /// pictures and videos according to the specified configuration. The camera
    /// interface is displayed as a full-screen modal that covers the entire screen
    /// and provides a native camera experience with capture controls.
    ///
    /// The camera configuration can be customized to control capture limits,
    /// video duration, media types, and other camera behavior settings.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the camera view is displayed
    ///   - preset: Configuration settings for the camera behavior (default: default configuration)
    ///   - onComplete: Closure called when the camera session completes with captured media
    /// - Returns: A SwiftUI view that presents the camera interface when activated
    public func presentTruvideoSdkCameraView(
        isPresented: Binding<Bool>,
        preset: TruvideoSdkCameraConfiguration = TruvideoSdkCameraConfiguration(),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            CameraView(configuration: preset, onCompleted: onComplete)
        }
    }
}
