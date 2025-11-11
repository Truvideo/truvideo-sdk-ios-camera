//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

extension UIViewController {
    /// Presents a full-screen camera interface for media capture.
    ///
    /// This function creates and presents a camera view that allows users to capture
    /// pictures and videos according to the specified configuration. The camera
    /// interface is displayed as a full-screen modal that covers the entire screen
    /// and provides a native camera experience with capture controls.
    ///
    /// The function uses UIKit's presentation system to show a SwiftUI camera view
    /// wrapped in a UIHostingController. The camera view is presented modally with
    /// full-screen presentation style, ensuring it takes over the entire display
    /// area for an immersive camera experience.
    ///
    /// The camera configuration can be customized to control capture limits,
    /// video duration, media types, and other camera behavior settings. When the
    /// user completes their capture session, the onComplete closure is called
    /// with the captured media results.
    ///
    /// - Parameters:
    ///   - preset: Configuration settings for the camera behavior (default: default configuration)
    ///   - onComplete: Closure called when the camera session completes with captured media
    @objc
    public func presentTruvideoSdkCameraView(
        preset: TruvideoSdkCameraConfiguration = TruvideoSdkCameraConfiguration(),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) {
        let hostingController = CameraHostingController(configuration: preset, onComplete: onComplete)
        hostingController.modalPresentationStyle = .fullScreen

        present(hostingController, animated: true)
    }
}
