//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Network
import UIKit
import Utilities

/// The `UploadProcessor` class is responsible for managing the persistence and upload of telemetry reports.
///
/// This class subscribes to telemetry events, writes incoming reports to disk using a provided `FileWriter`,
/// and manages the upload of stored reports to a remote server when network connectivity is available.
/// It also handles file rotation based on a configurable size limit, ensuring that log files do not exceed a specified size.
///
/// `UploadProcessor` is designed to operate efficiently in the background, responding to app lifecycle events and
/// network status changes to ensure reliable delivery of telemetry data.
final class UploadProcessor: TelemetryManagerSubscriber {
    // MARK: - Private Properties

    private var connectionStatus: NWPath.Status = .unsatisfied
    private var fileManager: FileManager
    private var fileURL: URL
    private let pathMonitor: any NetworkPathMonitor
    private let queue = DispatchQueue(label: "com.networking.session.queue")

    // MARK: - Dependencies

    @Dependency(\.fileWriter)
    var fileWriter: FileWriter

    @Dependency(\.uploader)
    var uploader: Uploader

    // MARK: - Initializer

    /// Initializes a new instance of `UploadProcessor`.
    ///
    /// - Parameters:
    ///   - fileManager:
    ///   - pathMonitor: The network path monitor for tracking network connectivity (default: new NWPathMonitor).
    ///   - storageURL: The directory URL where telemetry log files are stored (default: FileManager.default.telemetryDirectory).
    init(
        fileManager: FileManager = FileManager.default,
        pathMonitor: some NetworkPathMonitor = NWPathMonitor(),
        storageURL: URL = FileManager.default.telemetryDirectory
    ) {

        self.fileManager = fileManager
        self.fileURL = storageURL.appendingPathComponent("reports.json")
        self.pathMonitor = pathMonitor

        pathMonitor.start(queue: queue)
    }

    deinit {
        pathMonitor.cancel()
    }

    // MARK: - TelemetryManagerSubscriber

    /// Called whenever a new telemetry report is published by the `TelemetryManager`.
    ///
    /// - Parameter report: A fully structured telemetry report containing contextual metadata, breadcrumbs, and event details.
    func didReceive(_ report: TelemetryReport) {
        do {
            try fileWriter.write(report, to: fileURL)
        } catch {
            // Logging could be added here to capture the failure reason.
        }

        guard pathMonitor.currentPath.status == .satisfied else {
            // Logging could be added here to capture the connectivity status.
            return
        }

        Task {
            do {
                let data = try Data(contentsOf: fileURL)

                if !data.isEmpty {
                    try await uploader.upload(data, fileName: fileURL.lastPathComponent, contentType: .json)
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                // Logging could be added here to capture the failure reason.
            }
        }
    }
}
