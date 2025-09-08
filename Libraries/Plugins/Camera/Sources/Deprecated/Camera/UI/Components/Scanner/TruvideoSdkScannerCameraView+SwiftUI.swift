//
//  TruvideoSdkScannerCameraView+SwiftUI.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 31/7/24.
//

import SwiftUI

struct ScannerCameraViewFullScreenPresenter: ViewModifier {

    /// A boolean indicating whether the preview is presented.
    var isPresented: Binding<Bool>
    /// Preset configuration
    var preset: TruvideoSdkScannerCameraConfiguration
    /// A callback with the recording result
    var onComplete: TruvideoSdkScannerCameraViewCallback

    /// The bridge to launch the view using the `fullScreenCover` modifier
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: isPresented) {
                TruvideoSdkScannerCameraView(preset: preset, onComplete: onComplete)
            }
    }

}

extension View {

    /// Present the camera view over the full screen
    /// - Parameters:
    ///   - isPresented: A boolean indicating whether the preview is presented.
    ///   - onComplete: A callback with the recording result
    /// - Returns: The modified view
    public func presentTruvideoSdkScannerCameraView(
        isPresented: Binding<Bool>,
        preset: TruvideoSdkScannerCameraConfiguration = .init(
            flashMode: .off,
            orientation: nil
        ),
        onComplete: @escaping TruvideoSdkScannerCameraViewCallback
    ) -> some View {
        modifier(
            ScannerCameraViewFullScreenPresenter(
                isPresented: isPresented,
                preset: preset,
                onComplete: onComplete
            )
        )
    }
}
