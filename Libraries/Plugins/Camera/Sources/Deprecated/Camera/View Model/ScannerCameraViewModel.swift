//
//  ScannerCameraViewModel.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 31/7/24.
//

import UIKit

final class ScannerCameraViewModel: CameraViewModelDeprecation {
    var scannedCode: TruvideoSdkCameraScannerCode?
    var selectedCode: TruvideoSdkCameraScannerCode?
    var validator: TruvideoSdkCameraScannerValidation?
    var dismissOnSuccess = false

    @Published var sessionStarted = false
    @Published var toastMessage = ""
    @Published var codeImage: UIImage?
    @Published var codeImageSize: CGSize?
    @Published private(set) var state = State.scanning

    enum State: Equatable {
        case scanning
        case failure
        case scanned
    }

    override func beginConfiguration() {
        super.beginConfiguration()

        recorder
            .$scannedCode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard
                    let self,
                    self.state == .scanning,
                    let code = $0,
                    self.page != .confirmCodeSelection,
                    !code.data.isEmpty
                else { return }
                self.scannedCode = code
                self.handle(code: code)
            })
            .store(in: &cancellables)

        recorder
            .$isRunningSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.sessionStarted = $0
                if $0 {
                    self?.recorder.configureMetadataObjects()
                    self?.turnTorchIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    override func toggleTorch() {
        let torchStatus = torchStatus == .off ? TorchStatus.on : .off
        try? recorder.setTorchMode(torchStatus.torchMode)
        self.torchStatus = torchStatus
    }

    func confirmCodeSelection() {
        selectedCode = scannedCode
        recordStatus = .finished
    }

    override func navigateToCameraView() {
        super.navigateToCameraView()
        resumeScanning(after: .now() + 3)
    }

    private func resumeScanning(after time: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.state = .scanning
        }
    }

    private func turnTorchIfNeeded() {
        if preset.flashMode == .on {
            try? recorder.setTorchMode(.on)
        }
    }

    private func handle(code: TruvideoSdkCameraScannerCode) {
        let validationResult = validate(code: code)
        if validationResult.accept {
            state = .scanned
            generateCodeImage(for: code)
            if dismissOnSuccess {
                confirmCodeSelection()
            } else {
                page = .confirmCodeSelection
            }
        } else {
            toastMessage = validationResult.message ?? "Invalid code"
            state = .failure
            showToast = true
            resumeScanning(after: .now() + 3)
        }
    }

    private func validate(code: TruvideoSdkCameraScannerCode) -> TruvideoSdkCameraScannerValidationResult {
        if let validator = validator {
            return validator(code)
        } else {
            return TruvideoSdkCameraScannerValidationResult.success()
        }
    }

    private func generateCodeImage(for code: TruvideoSdkCameraScannerCode) {
        let isBarCode = code.format == .code39 || code.format == .code93
        codeImageSize = isBarCode ? .init(width: 108, height: 54) : .init(width: 54, height: 54)
        generateCodeImage(
            from: code.data,
            filter: isBarCode ? "CICode128BarcodeGenerator" : "CIQRCodeGenerator"
        )
    }

    private func generateCodeImage(from string: String, filter: String) {
        // Convert the input string to Data
        let data = string.data(using: .utf8)

        // Create the CIFilter with the QR code generator
        guard let filter = CIFilter(name: filter) else { return }
        filter.setValue(data, forKey: "inputMessage")

        // Get the output CIImage
        guard let ciImage = filter.outputImage else { return }

        // Convert the scaled CIImage to a CGImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        // Convert the CGImage to a UIImage
        codeImage = UIImage(cgImage: cgImage)
    }
}
