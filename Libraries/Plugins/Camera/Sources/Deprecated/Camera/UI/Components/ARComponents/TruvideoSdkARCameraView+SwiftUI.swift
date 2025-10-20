//
// Created by TruVideo on 21/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import SwiftUI

struct CameraViewFullScreenPresenter<V: View>: ViewModifier {

    /// A boolean indicating whether the preview is presented.
    var isPresented: Binding<Bool>
    /// A builder to render the view
    var viewBuilder: () -> V

    /// The bridge to launch the view using the `fullScreenCover` modifier
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: isPresented) {
                viewBuilder()
            }
            .onChange(of: isPresented.wrappedValue) { isPresented in
                if isPresented {
                    TruvideoSdkOrientationManager.shared.appIsActive = true
                    TruvideoSdkOrientationManager.shared.cameraInterface = .swiftui
                } else {
                    TVCameraFactory.shared.releaseCameraResources()
                }
            }
    }

}

extension View {
    /// Present the AR camera view over the full screen
    ///
    /// - Parameters:
    ///   - isPresented: A boolean indicating whether the preview is presented.
    ///   - preset: A preset to configure de AR Camera
    ///   - onComplete: A callback with the recording result
    /// - Returns: The modified view.
    public func presentTruvideoSdkARCameraView(
        isPresented: Binding<Bool>,
        preset: TruvideoSdkARCameraConfiguration = .init(flashMode: .off, mode: .videoAndPicture()),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> some View {
        let preset: TruvideoSdkCameraConfiguration = .init(
            flashMode: preset.flashMode,
            lensFacing: .back,
            mode: preset.mode,
            outputPath: ""
        )

        return modifier(
            CameraViewFullScreenPresenter(
                isPresented: isPresented,
                viewBuilder: { makeARCameraView(preset: preset, onComplete: onComplete) }
            )
        )
    }

    @ViewBuilder
    private func makeARCameraView(
        preset: TruvideoSdkCameraConfiguration,
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> some View {
        TruvideoSdkARCameraView(preset: preset, onComplete: onComplete)
    }
}
