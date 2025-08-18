//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    /// Returns the neutral zoom factor that provides the natural, unzoomed field of view.
    ///
    /// Different device types require different compensation:
    /// - Triple camera devices need 0.5x compensation for optimal wide lens usage
    /// - Dual camera devices need 0.3x compensation for balanced lens selection
    /// - Single camera devices require no compensation (0.0x)
    ///
    /// - Returns: A `CGFloat` representing the neutral zoom factor that provides the natural, unzoomed field of view for the current device type.
    var neutralZoomFactor: CGFloat {
        let lensCompensation =
            switch deviceType {
            case .builtInTripleCamera:
                0.5

            case .builtInDualWideCamera,
                .builtInDualCamera:

                0.3

            default:
                0.0
            }

        return dualCameraSwitchOverVideoZoomFactor + lensCompensation
    }

    /// Returns the preferred device types for camera selection in priority order.
    ///
    /// This static property defines the priority hierarchy for selecting camera devices,
    /// ordered from highest to lowest priority. The system will automatically return
    /// available cameras in this order when using AVCaptureDevice.DiscoverySession.
    ///
    /// Priority order is designed to provide the best camera experience:
    /// - Triple camera devices offer the most comprehensive zoom range
    /// - Dual camera devices provide good telephoto capabilities
    /// - Single camera devices serve as reliable fallbacks
    ///
    /// - Returns: An array of device types ordered by priority, from highest to lowest.
    static var preferredDeviceTypes: [AVCaptureDevice.DeviceType] {
        [
            .builtInTripleCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTelephotoCamera,
            .builtInUltraWideCamera,
            .builtInWideAngleCamera,
        ]
    }

    /// Returns the video devices capture device for the specified camera position.
    ///
    /// Searches the system’s available cameras for the given `position` using a priority
    /// order of device types (e.g., multi‑camera first, then wide/ultra‑wide/telephoto),
    /// and returns the first match. If none of the preferred types are available, the
    /// first discovered device for that position is returned. If no devices are found,
    /// `nil` is returned.
    ///
    /// Preference order:
    /// - `.builtInDualCamera`
    /// - `.builtInTripleCamera`
    /// - `.builtInWideAngleCamera`
    /// - `.builtInUltraWideCamera`
    /// - `.builtInTelephotoCamera`
    /// - `.builtInDualWideCamera`
    /// - `.builtInTrueDepthCamera`
    ///
    /// - Parameter position: The desired physical camera position (e.g., `.back`, `.front`).
    /// - Returns: The preferred `AVCaptureDevice` for the given position, or `nil` if unavailable.
    static func availableVideoDevices(for position: AVCaptureDevice.Position) -> [AVCaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: preferredDeviceTypes,
            mediaType: .video,
            position: position
        )

        return discoverySession.devices
    }
    
    // MARK: - Instance methods
    
    /// Sets the focus and exposure point to the specified location on the camera view.
    ///
    /// This method configures both focus and exposure settings to use the same point,
    /// ensuring that the camera focuses on and meters exposure for the same area of the scene.
    /// The method automatically handles device locking and unlocking to prevent configuration
    /// conflicts during the focus and exposure adjustment process.
    ///
    /// - Parameter point: The normalized point (0.0 to 1.0) where focus and exposure should be set.
    /// - Throws: An error if the device cannot be locked for configuration.
    func setFocusPoint(at point: CGPoint) throws {
        try lockForConfiguration()

        defer { unlockForConfiguration() }

        if isFocusPointOfInterestSupported, isFocusModeSupported(.autoFocus) {
            focusPointOfInterest = point
            focusMode = .autoFocus
        }

        if isExposurePointOfInterestSupported {
            exposurePointOfInterest = point
            exposureMode = .autoExpose
        }
    }
    
    /// Configures the capture device with recommended real‑time defaults for video capture.
    ///
    /// Applies continuous autofocus (enabling smooth autofocus when supported), continuous auto exposure,
    /// continuous auto white balance, automatic low‑light boost (when available), and subject‑area change
    /// monitoring. It also sets a fixed frame rate of 24 fps by assigning both `activeVideoMinFrameDuration`
    /// and `activeVideoMaxFrameDuration` to 1/24. The device is locked for configuration at the start and
    /// is always unlocked before returning, regardless of success.
    func configure() throws {
        try lockForConfiguration()
        defer { unlockForConfiguration() }

        if isFocusModeSupported(.continuousAutoFocus) {
            focusMode = .continuousAutoFocus

            if isSmoothAutoFocusSupported {
                isSmoothAutoFocusEnabled = true
            }
        }

        if isExposureModeSupported(.continuousAutoExposure) {
            exposureMode = .continuousAutoExposure
        }

        if isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            whiteBalanceMode = .continuousAutoWhiteBalance
        }

        if isLowLightBoostSupported {
            automaticallyEnablesLowLightBoostWhenAvailable = true
        }

        isSubjectAreaChangeMonitoringEnabled = true
        videoZoomFactor = neutralZoomFactor

        let fps = 30.0
        let videoSupportedFrameRatesRanges = activeFormat.videoSupportedFrameRateRanges

        if videoSupportedFrameRatesRanges.contains(where: { ($0.minFrameRate ... $0.maxFrameRate).contains(fps) }) {
            let frameDuration = CMTimeMake(value: 1, timescale: Int32(fps))

            activeVideoMinFrameDuration = frameDuration
            activeVideoMaxFrameDuration = frameDuration
        }
    }
}
