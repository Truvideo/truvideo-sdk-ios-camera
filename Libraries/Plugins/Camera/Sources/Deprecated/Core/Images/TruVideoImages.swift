//
//  TruVideoImages.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import SwiftUI

extension Image {
    /// Indicates whether SwiftUI renders an image as-is, or
    /// by using a different mode.
    ///
    /// - Parameters:
    ///    - renderingMode: The mode SwiftUI uses to render images.
    ///    - color: The color to apply to the image.
    /// - Returns: A modified ``View``.
    func withRenderingMode(_ renderingMode: Image.TemplateRenderingMode?, color: Color) -> some View {
        self.renderingMode(.template)
            .foregroundColor(color)
    }
}

/// Defines the images for the GetTransparency UI Kit.
struct TruVideoImage {
    /// Bolt fill
    static let boltFill = Image(systemName: "bolt.fill")

    /// Bolt slash fill
    static let boltSlashFill = Image(systemName: "bolt.slash.fill")

    /// Camera
    static let camera = Image(systemName: "camera")

    /// Category
    static let category = Image(systemName: "rectangle.stack.fill")

    /// Checkmark
    static let checkmark = Image(systemName: "checkmark")

    /// Close
    static let close = Image(systemName: "xmark")

    /// Chevron backward
    static let chevronBackward = Image(systemName: "chevron.backward")

    /// Chevron right
    static let chevronRight = Image(systemName: "chevron.right")

    ///  Undo
    static let undo = Image(systemName: "arrow.uturn.backward")

    /// Clear
    static let clear = Image(systemName: "trash")

    /// 3D objects
    static let arrows3D = Image(systemName: "move.3d")

    /// Ruler
    static let ruler = Image(systemName: "ruler")

    /// Ruler
    static let video = Image(systemName: "video")

    /// Flip camera
    static let flipCamera = Image(systemName: "arrow.triangle.2.circlepath.camera")

    /// Images
    static let image = Image(systemName: "photo")

    /// Microphone slash fill
    static let microphoneSlasFill = Image(systemName: "mic.slash.fill")

    /// Microphone fill
    static let microphoneFill = Image(systemName: "mic.fill")

    /// Noise cancelation
    static let noiseCancellation = Image(systemName: "phone.and.waveform.fill")

    /// Pause
    static let pause = Image(systemName: "pause.fill")

    /// Photo
    static let photo = Image(systemName: "photo.fill")

    /// Play
    static let play = Image(systemName: "play.fill")

    /// Rotate camera
    static let rotateCamera = Image("rotate-camera")

    /// Settings
    static let settings = Image(systemName: "gearshape")

    /// Screen recording
    static let recordingScreen = Image("recording-screen", bundle: Bundle(identifier: currentBundle))

    /// Trash
    static let trash = Image(systemName: "trash.fill")

    /// Resolution - High quality
    static let highDefinition = Image("high-definition", bundle: Bundle(identifier: currentBundle))

    static let tapToFocus = UIImage(
        named: "tap-to-focus",
        in: Bundle(identifier: TruVideoImage.currentBundle),
        with: nil
    )

    /// Current Bundle for loading local images
    static let currentBundle: String = "com.truvideo.TruvideoSdkCamera"

    static let flash = Image("flash", bundle: Bundle(identifier: currentBundle))

    static let fullHD = Image("full-hd", bundle: Bundle(identifier: currentBundle))

    static let flipCameraIcon = Image("flip-camera", bundle: Bundle(identifier: currentBundle))

    static let onboardingObjectModeIcon = Image("onboarding-object-mode", bundle: Bundle(identifier: currentBundle))

    static let onboardingRecordModeIcon = Image("onboarding-record-mode", bundle: Bundle(identifier: currentBundle))

    static let onboardingRulerModeIcon = Image("onboarding-ruler-mode", bundle: Bundle(identifier: currentBundle))

    static var blackImage: UIImage {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
