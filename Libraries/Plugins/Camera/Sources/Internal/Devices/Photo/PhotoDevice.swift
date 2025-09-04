//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
internal import Utilities

/// A device implementation for capturing photos using AVFoundation's photo capture system.
///
/// `CapturePhotoDevice` provides a complete photo capture solution by managing
/// `AVCapturePhotoOutput` and integrating with `AVCaptureSession`. It handles
/// device authorization, session configuration, and photo capture operations
/// while providing a clean interface for photo capture functionality.
final class PhotoDevice: NSObject, Device {
    // MARK: - Private Properties

    private let identifier = UUID()
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureSession: AVCaptureSession?
    private var continuation: CheckedContinuation<Photo?, Error>?
    private var fileNameCount = 1
    private var needsConfiguration = true

    // MARK: - Properties

    /// The configuration settings for photo capture operations.
    ///
    /// This property provides access to the device's configuration settings,
    /// including photo format preferences, quality settings, and other
    /// capture parameters that affect photo output.
    let configuration = PhotoDeviceConfiguration()

    /// Output directory for the device.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    // MARK: - Computed Properties

    /// The current authorization status for camera access.
    ///
    /// This property provides the current authorization status for video
    /// (camera) access. It's used to determine whether the device can
    /// be configured and used for photo capture operations.
    ///
    /// - Returns: The current authorization status for camera access.
    var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    // MARK: - Initializer

    /// Creates a new instance of the `CapturePhotoDevice`.
    nonisolated override init() {}

    // MARK: - Device

    /// Configures the device for use with the specified capture session.
    ///
    /// This function sets up the device with the necessary configuration to work with the given
    /// AVCaptureSession. It handles device initialization, format selection, and session integration
    /// to ensure the device is ready for capture operations.
    ///
    /// - Parameter session: The AVCaptureSession to configure the device with.
    /// - Throws: UtilityError if the device configuration fails or cannot be completed.
    @DeviceActor
    func configure(in session: AVCaptureSession) throws(UtilityError) {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.notAuthorized,
                failureReason: "This app doesn’t have permission to use the camera."
            )
        }

        session.beginConfiguration()

        defer { session.commitConfiguration() }

        let capturePhotoOutput = AVCapturePhotoOutput()

        if session.canAddOutput(capturePhotoOutput) {
            session.addOutput(capturePhotoOutput)
        } else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.cannotAddOutput,
                failureReason: "Unable to add \(capturePhotoOutput.debugDescription) to the session."
            )
        }

        self.capturePhotoOutput = capturePhotoOutput
        self.captureSession = session
        self.needsConfiguration = false
    }

    /// Stops capture for this device and removes any installed inputs/outputs from the session.
    ///
    /// Implementations should safely detach inputs/outputs and perform any necessary cleanup.
    /// Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` from which to remove this device’s input/output.
    @DeviceActor
    func endCapturing(in session: AVCaptureSession) {
        if let captureSession {
            captureSession.beginConfiguration()

            defer { captureSession.commitConfiguration() }

            if let capturePhotoOutput {
                captureSession.removeOutput(capturePhotoOutput)

                self.capturePhotoOutput = nil
            }

            self.captureSession = nil
        }
    }

    /// Pauses capture for this device without removing it from the session.
    ///
    /// Implementations should temporarily stop processing or capturing data while maintaining
    /// the device's connection to the session. This allows for quick resumption of capture
    /// without the overhead of reconfiguring inputs/outputs.
    @DeviceActor
    func pause() {}

    /// Resumes capture for this device after it has been paused.
    ///
    /// This method restarts data capture for a previously paused device. The device
    /// should return to the same state it was in before `pause()` was called.
    ///
    /// Implementations should:
    /// - Restart data processing
    /// - Resume any recording or streaming operations
    /// - Restore previous device settings if needed
    /// - Handle any state changes that occurred during the pause
    @DeviceActor
    func resume() {}

    /// Configures and starts capture for this device on the given session.
    ///
    /// Implementations typically validate authorization, resolve an `AVCaptureDevice`,
    /// install an `AVCaptureDeviceInput` and any required outputs, and update connection
    /// settings as needed. Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` to which inputs/outputs will be added.
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be added to the session due to incompatibility.
    @DeviceActor
    func startCapturing() throws(UtilityError) {}

    // MARK: - Instance methods

    /// Captures a photo using the configured photo output and settings.
    ///
    /// This function initiates an asynchronous photo capture operation using the current
    /// configuration settings. It performs validation checks to ensure the device is
    /// properly configured and no other capture operation is in progress. The capture
    /// is performed using `withCheckedThrowingContinuation` to bridge the delegate-based
    /// AVCapturePhotoOutput API with async/await.
    ///
    /// The function configures AVCapturePhotoSettings based on the current configuration,
    /// including high-resolution settings, flash mode, and quality prioritization.
    /// The actual capture is performed on the main actor to ensure proper delegate
    /// callback handling.
    ///
    /// - Returns: A Photo object containing the captured image data, or nil if the photo output is not available.
    /// - Throws: A UtilityError if the device needs configuration or if another photo capture is already in progress.
    func capturePhoto() async throws -> Photo? {
        guard !needsConfiguration else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.needsConfiguration,
                failureReason: "Device needs to be configured."
            )
        }

        guard continuation == nil else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Photo Capture already in progress."
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                guard let capturePhotoOutput else {
                    return continuation.resume(returning: nil)
                }

                let isHighResolutionEnabled = configuration.isHighResolutionEnabled
                let capturePhotoSettings = AVCapturePhotoSettings(
                    rawPixelFormatType: 0,
                    rawFileType: nil,
                    processedFormat: configuration.makeSettingsDictionary(),
                    processedFileType: configuration.format.fileType
                )

                capturePhotoOutput.isHighResolutionCaptureEnabled = isHighResolutionEnabled

                capturePhotoSettings.flashMode = configuration.flashMode
                capturePhotoSettings.isHighResolutionPhotoEnabled = isHighResolutionEnabled
                capturePhotoSettings.photoQualityPrioritization = .balanced

                self.continuation = continuation
                await MainActor.run {
                    capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: self)
                }
            }
        }
    }

    /// Requests camera (video) permission from the user.
    ///
    /// Presents the system authorization dialog if the status is `.notDetermined`.
    @discardableResult
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    // MARK: - Private methods

    private func nextOutputURL() -> URL {
        let filename = "\(identifier)-TV-photo.\(fileNameCount).\(configuration.format.rawValue)"
        fileNameCount += 1

        return outputDirectory.appendingPathComponent(filename)
    }
}

extension PhotoDevice: AVCapturePhotoCaptureDelegate {

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            continuation = nil
        }

        if let continuation {
            if let error {
                let error = UtilityError(kind: .PhotoDeviceErrorReason.failedToCapturePhoto, underlyingError: error)

                continuation.resume(throwing: error)
                return
            }

            do {
                let data = try photo.imageData(with: configuration.format)
                let outputURL = nextOutputURL()
                let photo = Photo(url: outputURL, format: configuration.format, orientation: .portrait)

                try data.write(to: outputURL, options: .atomic)

                continuation.resume(returning: photo)
            } catch {
                let error = UtilityError(kind: .PhotoDeviceErrorReason.failedToCapturePhoto, underlyingError: error)
                continuation.resume(throwing: error)
            }
        }
    }
}

extension AVCapturePhoto {
    /// Converts the photo to the specified file format and returns the data representation.
    ///
    /// This function processes the captured photo data according to the requested file format.
    /// For HEIC and JPEG formats, it returns the original data representation directly.
    /// For PNG format, it converts the data to a UIImage and then generates PNG data,
    /// which may involve format conversion and re-encoding.
    ///
    /// The function handles format-specific processing requirements, ensuring that
    /// the output data is properly encoded for the target format. PNG conversion
    /// requires additional processing steps compared to the other formats.
    ///
    /// - Parameter fileFormat: The desired output format for the photo data
    /// - Returns: The photo data encoded in the specified format
    /// - Throws: A UtilityError if the data representation cannot be obtained or if PNG conversion fails
    fileprivate func imageData(with fileFormat: FileFormat) throws(UtilityError) -> Data {
        guard let data = fileDataRepresentation() else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        guard fileFormat == .png else {
            return data
        }

        guard let data = UIImage(data: data)?.pngData() else {
            throw UtilityError(
                kind: .PhotoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        return data
    }
}
