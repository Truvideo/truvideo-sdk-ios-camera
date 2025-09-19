//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureSession {
    // MARK: - Notification Names

    /// Notification name posted when a capture session has completed configuration updates.
    ///
    /// This notification is posted after `commitConfiguration()` is called on an `AVCaptureSession`,
    /// indicating that all pending configuration changes have been applied and the session is
    /// now in its new configured state. Observers can use this notification to react to completed
    /// session changes, update UI elements, or perform cleanup operations.
    ///
    /// The notification object is the `AVCaptureSession` instance that has completed updates.
    /// This allows observers to identify which specific session has been reconfigured when
    /// multiple sessions are present in the application.
    ///
    /// ## Usage Example
    ///
    /// ```swift
    /// NotificationCenter.default.addObserver(
    ///     self,
    ///     selector: #selector(sessionDidEndUpdates(_:)),
    ///     name: AVCaptureSession.didEndUpdates,
    ///     object: nil
    /// )
    ///
    /// @objc private func sessionDidEndUpdates(_ notification: Notification) {
    ///     guard let session = notification.object as? AVCaptureSession else { return }
    ///     print("Session \(session) has completed configuration updates")
    ///     // Update UI or perform post-configuration tasks
    /// }
    /// ```
    nonisolated static let didEndUpdates = Notification.Name("com.truvideo.session.didEndUpdates")

    /// Notification name posted when a capture session has completed configuration updates.
    ///
    /// This notification is posted after `commitConfiguration()` is called on an `AVCaptureSession`,
    /// indicating that all pending configuration changes have been applied and the session is
    /// now in its new configured state. Observers can use this notification to react to completed
    /// session changes, update UI elements, or perform cleanup operations.
    ///
    /// The notification object is the `AVCaptureSession` instance that has completed updates.
    /// This allows observers to identify which specific session has been reconfigured when
    /// multiple sessions are present in the application.
    ///
    /// ## Usage Example
    ///
    /// ```swift
    /// NotificationCenter.default.addObserver(
    ///     self,
    ///     selector: #selector(sessionDidCommitUpdates(_:)),
    ///     name: AVCaptureSession.didCommitUpdates,
    ///     object: nil
    /// )
    ///
    /// @objc private func sessionDidCommitUpdates(_ notification: Notification) {
    ///     guard let session = notification.object as? AVCaptureSession else { return }
    ///     print("Session \(session) has completed configuration updates")
    ///     // Update UI or perform post-configuration tasks
    /// }
    /// ```
    nonisolated static let willBeginUpdates = Notification.Name("com.truvideo.session.willBeginUpdates")

    // MARK: - Instance methods

    /// Begins a configuration update session with notification support.
    ///
    /// This function initiates a configuration update cycle for the capture session by
    /// first posting a notification to inform observers that configuration changes are
    /// about to begin, then calling `beginConfiguration()` to start the actual configuration
    /// process. This provides a coordinated approach to session configuration that allows
    /// other components to prepare for and respond to configuration changes.
    ///
    /// The function follows a two-step process:
    /// 1. Posts `willBeginUpdates` notification to alert observers
    /// 2. Calls `beginConfiguration()` to start the configuration session
    ///
    /// This ensures that any observers registered for the `willBeginUpdates` notification
    /// have advance notice before the session enters configuration mode, allowing them to
    /// prepare for potential state changes or coordinate their own operations with the
    /// session configuration lifecycle.
    ///
    /// ## Usage Example
    ///
    /// ```swift
    /// // Begin configuration updates
    /// captureSession.beginUpdates()
    ///
    /// // Make configuration changes
    /// captureSession.addInput(newInput)
    /// captureSession.addOutput(newOutput)
    ///
    /// // Commit the changes
    /// captureSession.commitUpdates()
    /// ```
    ///
    /// ## Notification Coordination
    ///
    /// This function works in conjunction with `commitUpdates()` to provide a complete
    /// configuration lifecycle with notification support:
    /// - `beginUpdates()` posts `willBeginUpdates` notification
    /// - `commitUpdates()` posts `didCommitUpdates` notification
    ///
    /// Observers can use these notifications to coordinate their operations with the
    /// session configuration process and ensure proper state management.
    func beginUpdates() {
        NotificationCenter.default.post(Self.willBeginUpdates, object: self)
        beginConfiguration()
    }

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

    /// Commits configuration updates and notifies observers of completion.
    ///
    /// This function finalizes a configuration update cycle for the capture session by
    /// first calling `commitConfiguration()` to apply all pending changes, then posting
    /// a notification to inform observers that the configuration process has completed.
    /// This provides a coordinated approach to session configuration that allows other
    /// components to react to completed changes and perform necessary updates.
    ///
    /// The function follows a two-step process:
    /// 1. Calls `commitConfiguration()` to apply all pending configuration changes
    /// 2. Posts `didEndUpdates` notification to alert observers of completion
    ///
    /// This ensures that any observers registered for the `didCommitUpdates` notification
    /// are notified after the session configuration has been successfully applied, allowing
    /// them to react to the new session state, update UI elements, or perform cleanup
    /// operations as needed.
    ///
    /// ## Usage Example
    ///
    /// ```swift
    /// // Begin configuration updates
    /// captureSession.beginUpdates()
    ///
    /// // Make configuration changes
    /// captureSession.addInput(newInput)
    /// captureSession.addOutput(newOutput)
    ///
    /// // Commit the changes
    /// captureSession.endUpdates()
    /// ```
    ///
    /// ## Notification Coordination
    ///
    /// This function works in conjunction with `beginUpdates()` to provide a complete
    /// configuration lifecycle with notification support:
    /// - `beginUpdates()` posts `willBeginUpdates` notification
    /// - `endUpdates()` posts `didEndUpdates` notification
    ///
    /// Observers can use these notifications to coordinate their operations with the
    /// session configuration process and ensure proper state management throughout
    /// the configuration lifecycle.
    func endUpdates() {
        commitConfiguration()
        NotificationCenter.default.post(Self.didEndUpdates, object: self)
    }
}
