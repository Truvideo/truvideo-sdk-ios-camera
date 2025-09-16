//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Combine
import CoreImage
import Foundation
import UIKit
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the photo controller device operations.
    ///
    /// The `CapturePhotoControllerErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the capture photo controller.
    struct CapturePhotoControllerErrorReason: Sendable {
        /// Error reason indicating that the photo output could not be configured for the capture session.
        ///
        /// This error occurs when the system is unable to add the photo output to the capture session,
        /// typically due to session configuration constraints or hardware limitations. The error is thrown
        /// when `AVCaptureSession.canAddOutput(_:)` returns `false`, preventing the photo capture
        /// functionality from being properly initialized.
        static let cannotConfigurePhotoOutput = ErrorReason(rawValue: "CANNOT_CONFIGURE_PHOTO_OUTPUT")

        /// Error reason indicating that photo capture operation failed.
        ///
        /// This error reason is used when a photo capture operation cannot be completed
        /// successfully. It may be thrown due to various issues such as device
        /// configuration problems, hardware unavailability, or capture settings
        /// incompatibility.
        static let failedToCapturePhoto = ErrorReason(rawValue: "CAPTURE_PHOTO_CONTROLLER_FAILED_TO_CAPTURE_PHOTO")
    }
}

/// A controller that manages photo capture operations using AVCapturePhotoOutput.
///
/// The `CapturePhotoController` class provides a high-level interface for capturing photos
/// using the AVFoundation framework. It encapsulates the complexity of managing photo
/// capture sessions, handling asynchronous capture operations, and processing captured
/// images with proper orientation and formatting.
final class CapturePhotoController: NSObject {
    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureSession: AVCaptureSession?
    private let context = CIContext.createDefault()
    private var lastPhotoCaptureDate = Date.distantFuture
    private var photoContinuations: [PhotoContinuation] = []
    private var photoQualityPrioritization = AVCapturePhotoOutput.QualityPrioritization.balanced
    private let speedQualityThreshold = 0.28
    private let shutterSubject = PassthroughSubject<Void, Never>()

    // MARK: - Types

    /// Configuration settings for photo capture operations.
    ///
    /// The `Configuration` struct encapsulates all the parameters needed to configure
    /// photo capture behavior, including device orientation, camera position, flash mode,
    /// image format, resolution settings, and output location. This configuration is
    /// used throughout the photo capture pipeline to ensure consistent behavior and
    /// proper image processing.
    struct Configuration {
        /// The device orientation during photo capture.
        ///
        /// This property specifies the orientation of the device when the photo is captured,
        /// which affects how the image is processed and displayed. The default value is
        /// portrait orientation, which is the most common use case for photo capture.
        let deviceOrientation = AVCaptureVideoOrientation.portrait

        /// The camera lens position used for photo capture.
        ///
        /// This property determines which camera lens is used to capture the photo,
        /// such as front-facing or back-facing camera. The choice affects the image
        /// orientation and mirroring behavior.
        let devicePosition: AVCaptureDevice.Position

        /// The flash mode to use during photo capture.
        ///
        /// This property determines how the camera's flash behaves when taking a photo.
        /// It can be set to different modes such as off, on, auto, or red-eye reduction
        /// to achieve the desired lighting effect for the captured image.
        let flashMode: AVCaptureDevice.FlashMode

        /// The desired output format for captured photos.
        ///
        /// This property specifies whether photos should be captured as JPEG or PNG
        /// format. The choice affects both the capture quality settings and the
        /// post-processing steps required to achieve the desired output format.
        let imageFormat: FileFormat

        /// Whether high-resolution photo capture is enabled.
        ///
        /// When enabled, this property allows the camera to capture photos at the
        /// device's maximum available resolution, which may be higher than the
        /// standard capture resolution. This is useful for applications requiring
        /// maximum detail and quality.
        let isHighResolutionEnabled: Bool

        /// The file URL where captured photos will be saved.
        ///
        /// This property specifies the location on the device's file system where
        /// captured photos will be stored. The URL must be writable and accessible
        /// to the application. The default value points to the temporary directory.
        let outputURL: URL
    }

    /// A wrapper that associates a photo capture configuration with its completion continuation.
    ///
    /// The `PhotoContinuation` struct serves as a bridge between the asynchronous photo capture
    /// request and its completion handler. It maintains the configuration used for the capture
    /// operation alongside the Swift continuation that will be resumed when the capture
    /// completes, either successfully with a Photo object or with an error.
    struct PhotoContinuation {
        /// The configuration settings used for this photo capture operation.
        let configuration: Configuration

        /// The continuation that will be resumed when the photo capture completes.
        let continuation: CheckedContinuation<Photo, Error>
    }

    // MARK: - Initializer

    /// Creates a new photo controller instance.
    override init() {
        super.init()

        shutterSubject.sink { [weak self] in
            if let self {
                let date = Date()
                let timeInterval = date.timeIntervalSince(lastPhotoCaptureDate)

                self.photoQualityPrioritization = timeInterval <= self.speedQualityThreshold ? .speed : .balanced
                self.lastPhotoCaptureDate = date
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - Instance methods

    /// Captures a photo using the specified configuration settings.
    ///
    /// This function initiates an asynchronous photo capture operation using the provided
    /// configuration parameters. It creates the appropriate photo settings, configures
    /// the capture output, and starts the capture process. The function uses a continuation-based
    /// approach to provide an async/await interface for photo capture completion.
    ///
    /// - Parameter configuration: The configuration settings specifying device position,
    ///                             flash mode, image format, resolution, and output location
    /// - Returns: A Photo object containing the captured image with metadata
    /// - Throws: An error if the capture process fails.
    func capturePhoto(with configuration: Configuration) async throws -> Photo {
        guard let capturePhotoOutput else {
            throw UtilityError(
                kind: .CapturePhotoControllerErrorReason.cannotConfigurePhotoOutput,
                failureReason: "AVCapturePhotoOutput has not been configured."
            )
        }

        shutterSubject.send(())

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                let capturePhotoSettings = AVCapturePhotoSettings.from(configuration)

                capturePhotoOutput.isHighResolutionCaptureEnabled = configuration.isHighResolutionEnabled
                capturePhotoSettings.flashMode = configuration.flashMode
                capturePhotoSettings.photoQualityPrioritization = photoQualityPrioritization

                let photoContinuation = PhotoContinuation(configuration: configuration, continuation: continuation)

                photoContinuations.append(photoContinuation)
                await MainActor.run {
                    capturePhotoOutput.setPreparedPhotoSettingsArray([capturePhotoSettings], completionHandler: nil)
                    capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: self)
                }
            }
        }
    }

    /// Configures the photo controller by adding a photo output to the capture session.
    ///
    /// This function initializes the photo capture functionality by creating a new
    /// AVCapturePhotoOutput and adding it to the provided capture session. The function
    /// performs validation to ensure the photo output can be successfully added to the
    /// session before attempting the configuration. If the output cannot be added due to
    /// session constraints or hardware limitations, the function throws an appropriate
    /// error with detailed failure information.
    ///
    /// - Parameter session: The AVCaptureSession to configure with photo capture capabilities
    /// - Throws: An error if the photo output cannot be added to the session
    func configure(in session: AVCaptureSession) throws(UtilityError) {
        let capturePhotoOutput = AVCapturePhotoOutput()

        if session.canAddOutput(capturePhotoOutput) {
            session.addOutput(capturePhotoOutput)

            if let capturePhotoOutputConnection = capturePhotoOutput.connection(with: .video) {
                capturePhotoOutputConnection.automaticallyAdjustsVideoMirroring = false
                capturePhotoOutputConnection.isVideoMirrored = false
            }
        } else {
            throw UtilityError(
                kind: .CapturePhotoControllerErrorReason.cannotConfigurePhotoOutput,
                failureReason: "Unable to add \(capturePhotoOutput.debugDescription) to the session."
            )
        }

        self.capturePhotoOutput = capturePhotoOutput
        self.captureSession = session
    }

    /// Destroys the photo controller by removing the photo output from the capture session.
    ///
    /// This function performs cleanup operations to properly tear down the photo capture
    /// functionality. It removes the photo output from the capture session and clears
    /// internal references to prevent memory leaks and ensure proper resource management.
    /// The function is designed to be safe to call multiple times and handles cases where
    /// the session or photo output may already be nil.
    func destroy() {
        if let captureSession, let capturePhotoOutput {
            captureSession.removeOutput(capturePhotoOutput)

            self.capturePhotoOutput = nil
        }
    }

    /// Sets the preferred video stabilization mode and applies it to the video connection.
    ///
    /// When supported by the active connection, the `preferredVideoStabilizationMode` is updated
    /// to match the requested `mode`. If not supported, the connection’s mode remains unchanged.
    ///
    /// - Parameter mode: The desired `AVCaptureVideoStabilizationMode` (e.g., `.auto`, `.standard`, `.cinematic`).
    func setStabilizationMode(_ mode: AVCaptureVideoStabilizationMode) {
        if let capturePhotoOutputConnection = capturePhotoOutput?.connection(with: .video) {
            if capturePhotoOutputConnection.isVideoStabilizationSupported {
                capturePhotoOutputConnection.preferredVideoStabilizationMode = mode
            }
        }
    }
}

extension CapturePhotoController: AVCapturePhotoCaptureDelegate {

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard !photoContinuations.isEmpty else {
            return
        }

        let photoContinuation = photoContinuations.removeFirst()

        if let error {
            let error = UtilityError(
                kind: .CapturePhotoControllerErrorReason.failedToCapturePhoto,
                underlyingError: error
            )

            photoContinuation.continuation.resume(throwing: error)
            return
        }

        do {
            guard
                /// Extracts and returns the captured photo's primary image.
                let cgImage = photo.cgImageRepresentation(),

                /// The Photo representation of the image.
                let photo = try context?.createImage(from: cgImage, configuration: photoContinuation.configuration)
            else {

                throw UtilityError(
                    kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                    failureReason: "Unable to get data representation of the photo."
                )
            }

            photoContinuation.continuation.resume(returning: photo)
        } catch {
            let error = UtilityError(
                kind: .CapturePhotoControllerErrorReason.failedToCapturePhoto,
                underlyingError: error
            )

            photoContinuation.continuation.resume(throwing: error)
        }
    }
}

extension AVCapturePhotoSettings {
    /// Creates an `AVCapturePhotoSettings` instance from a video device configuration.
    ///
    /// This method converts a `VideoDeviceConfiguration` into the corresponding
    /// `AVCapturePhotoSettings` object used by the camera capture system. It configures
    /// the photo settings with the specified image format, quality settings, and
    /// resolution options from the configuration object.
    ///
    /// - Parameter configuration: The video device configuration containing image format and quality settings
    /// - Returns: A configured `AVCapturePhotoSettings` instance ready for photo capture
    fileprivate static func from(_ configuration: CapturePhotoController.Configuration) -> AVCapturePhotoSettings {
        let capturePhotoSettings = AVCapturePhotoSettings(
            rawPixelFormatType: 0,
            rawFileType: nil,
            processedFormat: [
                AVVideoCodecKey: configuration.imageFormat.codec,
                AVVideoCompressionPropertiesKey: [
                    AVVideoQualityKey: NSNumber(value: configuration.imageFormat.quality)
                ],
            ],
            processedFileType: configuration.imageFormat.fileType
        )

        capturePhotoSettings.isHighResolutionPhotoEnabled = configuration.isHighResolutionEnabled

        return capturePhotoSettings
    }
}

extension CIContext {
    /// Creates a Photo object from a Core Graphics image with proper orientation and formatting.
    ///
    /// This function processes a raw CGImage by applying the correct orientation based on device
    /// position and orientation, converts it to the specified image format, and saves it to
    /// the configured output URL. The function handles the complete pipeline from raw image
    /// data to a fully-formed Photo object with metadata.
    ///
    /// - Parameters:
    ///   - cgImage: The raw Core Graphics image to process
    ///   - configuration: The capture configuration containing device orientation, position, image format,
    ///                    and output URL settings
    /// - Returns: A Photo object containing the processed image with metadata
    /// - Throws: An error if image processing or data conversion fails
    func createImage(from cgImage: CGImage, configuration: CapturePhotoController.Configuration) throws -> Photo {
        let orientation = CGImagePropertyOrientation(
            from: configuration.deviceOrientation,
            devicePosition: configuration.devicePosition
        )

        let ciiImage = CIImage(cgImage: cgImage).oriented(orientation)

        guard
            /// The new image from the photo.
            let image = createCGImage(ciiImage, from: ciiImage.extent).map(UIImage.init(cgImage:)),

            /// The image data representation.
            let data = image.data(with: configuration.imageFormat)
        else {

            throw UtilityError(
                kind: .CapturePhotoControllerErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        try data.write(to: configuration.outputURL, options: .atomic)

        return Photo(
            url: configuration.outputURL,
            format: configuration.imageFormat,
            lensPosition: configuration.devicePosition,
            orientation: UIDeviceOrientation(from: configuration.deviceOrientation)
        )
    }
}
