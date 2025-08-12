//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    /// Returns the preferred video capture device for the specified camera position.
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
    static func defaultVideoDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let allDeviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInDualCamera,
            .builtInTripleCamera,
            .builtInWideAngleCamera,
            .builtInUltraWideCamera,
            .builtInTelephotoCamera,
            .builtInDualWideCamera,
            .builtInTrueDepthCamera,
        ]

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: allDeviceTypes,
            mediaType: .video,
            position: position
        )

        let devices = discoverySession.devices

        for preferredType in allDeviceTypes {
            if let device = discoverySession.devices.first(where: { $0.deviceType == preferredType }) {
                return device
            }
        }

        return devices.first
    }
}
