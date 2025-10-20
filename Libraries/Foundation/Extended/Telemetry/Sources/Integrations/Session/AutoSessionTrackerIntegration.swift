//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import StorageKit
import UIKit

/// An integration that automatically manages telemetry sessions based on app lifecycle events.
///
/// The `AutoSessionTrackerIntegration` listens for key `UIApplication` notifications such as when the app
/// becomes active, resigns activity, or is about to terminate. Based on these events, it intelligently starts or ends
/// sessions depending on how long the app has been inactive.
///
/// This integration helps ensure that session boundaries are well-defined without requiring manual intervention.
final class AutoSessionTrackerIntegration: TelemetryIntegration {
    // MARK: - Private Properties

    private let application: UIApplication
    private let defaultSessionDuration: TimeInterval = 120
    private var previousForegroundDate: Date?

    private weak var telemetryManager: TelemetryManager?

    // MARK: - Dependencies

    @Dependency(\.storage)
    var storage: Storage

    // MARK: - Types

    /// A key used for storing the timestamp when the app was last in the foreground.
    struct PreviousForegroundDateStorageKey: StorageKey {
        /// The associated value type that will be stored and retrieved using this key.
        typealias Value = Date
    }

    // MARK: - Initializer

    /// Creates a new instance of the `AutoSessionTrackerIntegration`.
    ///
    /// - Parameter application: The centralized point of control and coordination for running apps.
    init(application: UIApplication = .shared) {
        self.application = application
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - TelemetryIntegration

    /// Installs the telemetry integration into the provided telemetry manager.
    ///
    /// - Parameter manager: The central `TelemetryManager` responsible for coordinating integrations.
    func install(on manager: TelemetryManager) {
        telemetryManager = manager
        startMonitoringAppLifecycleChanges()

        Task { @MainActor in
            if application.applicationState == .active {
                startSession()
            }
        }
    }

    // MARK: - Notification methods

    @objc
    func didReceiveBecomeActiveNotification(_ notification: Notification) {
        startSession()
    }

    @objc
    func didReceiveWillResignActiveNotification(_ notification: Notification) {
        let date = Date()

        previousForegroundDate = date

        do {
            try storage.write(date, forKey: PreviousForegroundDateStorageKey.self)
        } catch {
            // LOG
        }
    }

    @objc
    func didReceiveWillTerminateNotification(_ notification: Notification) {
        let endedAt = previousForegroundDate ?? Date()

        telemetryManager?.endSession(at: endedAt)

        do {
            try storage.deleteValue(for: PreviousForegroundDateStorageKey.self)
        } catch {
            // LOG
        }
    }

    // MARK: - Private methods

    private func startMonitoringAppLifecycleChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillTerminateNotification(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    private func startSession() {
        do {
            previousForegroundDate = try storage.readValue(for: PreviousForegroundDateStorageKey.self)

            guard let previousForegroundDate else {
                telemetryManager?.startSession()
                return
            }

            let secondsElapsed = Date().timeIntervalSince(previousForegroundDate)

            if secondsElapsed > defaultSessionDuration {
                telemetryManager?.endSession(at: previousForegroundDate)
                telemetryManager?.startSession()
            }
        } catch {
            // LOG
            /// Falls back to a new session if the current session cannot be restored or an error occurs.
            telemetryManager?.startSession()
        }
    }
}
