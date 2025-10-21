//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

/// Observes camera device adjustments and notifies when all adjustments have settled.
///
/// This class monitors the adjustment state of focus, exposure, and white balance
/// on an `AVCaptureDevice` and provides a callback when all adjustments are complete.
/// It uses Key-Value Observing (KVO) to track changes in the device's adjustment
/// properties and determines when the camera has finished all automatic adjustments.
final class FocusObserver: NSObject {
    // MARK: - Private Properties

    private var didResetFocus = false
    private var observations: [NSKeyValueObservation] = []
    private var onFocusChanged: ((AVCaptureDevice) -> Void)?
    private var subjectAreaObserver: NSObjectProtocol?

    // MARK: - Deinitializer

    deinit {
        observations.removeAll()
        subjectAreaObserver = nil
    }

    // MARK: - Instance methods

    /// Starts observing the specified capture device for adjustment state changes.
    ///
    /// Sets up Key-Value observations for focus, exposure, and white balance
    /// adjustment states. The provided callback will be executed when all
    /// adjustments have settled (no longer adjusting).
    ///
    /// - Parameters:
    ///   - captureDevice: The `AVCaptureDevice` to observe for adjustment changes
    ///   - onFocusChanged: Closure to execute when all adjustments are complete
    func startObserving(_ captureDevice: AVCaptureDevice, onFocusChanged: @escaping ((AVCaptureDevice) -> Void)) {
        self.onFocusChanged = onFocusChanged
        didResetFocus = false
        observations.removeAll()

        if subjectAreaObserver == nil {
            subjectAreaObserver = NotificationCenter.default.addObserver(
                forName: .AVCaptureDeviceSubjectAreaDidChange,
                object: captureDevice,
                queue: .main
            ) { [weak self] notification in
                self?.didReceiveCaptureDeviceSubjectAreaDidChange(notification)
            }
        }

        observations = [
            captureDevice.observe(\.isAdjustingExposure, options: [.new]) { [weak self] captureDevice, _ in
                self?.maybeSettled(captureDevice)
            },
            captureDevice.observe(\.isAdjustingFocus, options: [.new]) { [weak self] captureDevice, _ in
                self?.maybeSettled(captureDevice)
            },
            captureDevice.observe(\.isAdjustingWhiteBalance, options: [.new]) { [weak self] captureDevice, _ in
                self?.maybeSettled(captureDevice)
            }
        ]
    }

    /// Stops observing device adjustments and cleans up resources.
    ///
    /// This method removes all active Key-Value observations and clears the focus
    /// changed callback. It should be called when the observer is no longer needed
    /// or when switching to observe a different device to prevent memory leaks
    /// and invalid observation attempts.
    func stopObserving() {
        observations.removeAll()
    }

    // MARK: - Notification methods

    @objc
    func didReceiveCaptureDeviceSubjectAreaDidChange(_ notification: Notification) {
        if let captureDevice = notification.object as? AVCaptureDevice, !didResetFocus {
            do {
                let focusPoint = CGPoint(x: 0.5, y: 0.5)
                try captureDevice.setFocusPoint(at: focusPoint)

                onFocusChanged?(captureDevice)
                onFocusChanged = nil
                didResetFocus = true
            } catch {
                // Log could be added here
                print(error)
            }
        }
    }

    // MARK: - Private methods

    private func maybeSettled(_ captureDevice: AVCaptureDevice) {
        if !captureDevice.isAdjustingFocus, !captureDevice.isAdjustingExposure, !captureDevice.isAdjustingWhiteBalance {
            Task { @MainActor in
                onFocusChanged?(captureDevice)
            }
        }
    }
}
