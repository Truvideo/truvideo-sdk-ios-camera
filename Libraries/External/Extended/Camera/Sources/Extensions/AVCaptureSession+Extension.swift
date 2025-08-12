//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureSession {
    /// Returns the first device input in the session that matches the specified media type.
    ///
    /// Scans the session’s current `inputs` and returns the first `AVCaptureDeviceInput` whose
    /// underlying `AVCaptureDevice` reports support for the given `mediaType` (e.g., `.video`, `.audio`).
    /// In configurations with multiple inputs of the same type (multi‑camera), this returns the first match;
    /// prefer a position‑aware or `uniqueID`‑aware helper if you need a specific device.
    ///
    /// - Parameter mediaType: The media type to match (for example, `.video` or `.audio`).
    /// - Returns: The first matching `AVCaptureDeviceInput` if present; otherwise, `nil`.
    /// - Note: Query and mutate the session on your dedicated session queue, ideally within
    ///   `beginConfiguration()` / `commitConfiguration()` to avoid transient inconsistencies.
    func captureDeviceInput(for mediaType: AVMediaType) -> AVCaptureDeviceInput? {
        guard let inputs = inputs as? [AVCaptureDeviceInput], !inputs.isEmpty else { return nil }

        return inputs.first { $0.device.hasMediaType(mediaType) }
    }
}
