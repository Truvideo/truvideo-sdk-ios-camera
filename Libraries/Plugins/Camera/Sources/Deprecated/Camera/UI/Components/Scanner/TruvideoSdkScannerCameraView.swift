//
// Created by TruVideo on 30/7/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import SwiftUI

/// A callback function that handles the result of a barcode or QR code scan.
///
/// The `TruvideoSdkScannerCameraViewCallback` is triggered when the scanner captures a barcode,
/// providing the scanned `TruvideoSdkCameraScannerCode` object.
///
/// - Parameter scannedCode: The scanned barcode or `nil` if the scan was unsuccessful.
public typealias TruvideoSdkScannerCameraViewCallback = (TruvideoSdkCameraScannerCode?) -> Void

struct TruvideoSdkScannerCameraView: View {
    private let onComplete: TruvideoSdkScannerCameraViewCallback

    /// The view model handling the logic and data for camera features.
    @StateObject private var viewModel: ScannerCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            if viewModel.isAuthenticated {
                ScannerCamera()
            } else {
                UnauthenticatedView {
                    onComplete(nil)
                }
            }
        }
        .environmentObject(viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear(perform: viewModel.beginConfiguration)
        .onChange(of: viewModel.recordStatus) { status in
            guard status == .finished else { return }
            onComplete(viewModel.selectedCode)
        }
    }

    // MARK: Initializers

    /// Creates a new instance of the `TruvideoSdkCameraView`.
    ///
    /// - Parameter onComplete: A callback to invoke when the recording session has finished.
    init(
        preset: TruvideoSdkScannerCameraConfiguration,
        onComplete: @escaping TruvideoSdkScannerCameraViewCallback
    ) {
        let viewModelPreset: TruvideoSdkCameraConfiguration = .init(
            flashMode: preset.flashMode,
            lensFacing: .back,
            mode: .video(),
            outputPath: ""
        )
        Logger.addLog(event: .openCamera, eventMessage: .cameraOpenWithConfiguration(preset: viewModelPreset))
        let recorder = TruVideoRecorder(capturedMode: .scanner)
        recorder.supportedCodeFormats = preset.codeFormats
        let viewModel = ScannerCameraViewModel(recorder: recorder, preset: viewModelPreset)
        self.onComplete = onComplete
        viewModel.validator = preset.validator
        viewModel.dismissOnSuccess = preset.autoClose
        viewModel.onStartHandler = {
            try recorder.start()
        }
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
