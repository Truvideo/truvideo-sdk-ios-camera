//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import CloudStorageKit
internal import DI
import Foundation
internal import Network
internal import Telemetry
import UIKit
internal import Utilities

/// A telemetry subscriber that processes and uploads telemetry reports to cloud storage.
///
/// This class implements the TelemetryManagerSubscriber protocol to handle
/// telemetry report processing and cloud upload functionality. It receives
/// telemetry reports from the TelemetryManager, writes them to local storage,
/// and uploads them to cloud storage when network connectivity is available.
///
/// The processor uses a dedicated dispatch queue for background operations
/// and monitors network connectivity to ensure uploads only occur when
/// the device is online. It implements automatic cleanup of local files
/// after successful cloud uploads to prevent storage bloat.
final class UploadProcessor: TelemetryManagerSubscriber {
    // MARK: - Private Properties

    private let cloudStorageProvider: CloudStorageProvider
    private var fileURL: URL
    private let queue = DispatchQueue(label: "com.truvideo.uploadProcessor.queue")
    private let pathMonitor: any NetworkPathMonitor

    // MARK: - Dependencies

    @Dependency(\.fileWriter)
    private var fileWriter: FileWriter

    // MARK: - Initializer

    /// Creates a new upload processor with cloud storage and network monitoring.
    ///
    /// This initializer sets up the upload processor with the necessary
    /// dependencies for cloud storage operations and network connectivity
    /// monitoring. Network monitoring is started immediately to ensure
    /// connectivity changes are detected from the beginning.
    ///
    /// - Parameters:
    ///   - cloudStorageProvider: The provider responsible for cloud storage operations.
    ///   - pathMonitor: Network path monitor for connectivity detection.
    ///   - storageURL: Local storage directory for telemetry data
    init(
        cloudStorageProvider: CloudStorageProvider,
        pathMonitor: some NetworkPathMonitor = NWPathMonitor(),
        storageURL: URL = FileManager.default.telemetryDirectory
    ) {
        self.cloudStorageProvider = cloudStorageProvider
        self.fileURL = storageURL.appendingPathComponent("report.json")
        self.pathMonitor = pathMonitor

        pathMonitor.start(queue: queue)
    }

    // MARK: - Deinitializer

    deinit {
        pathMonitor.cancel()
    }

    // MARK: - TelemetryManagerSubscriber

    /// Called whenever a new telemetry report is published by the `TelemetryManager`.
    ///
    /// - Parameter report: A fully structured telemetry report containing contextual metadata, breadcrumbs, and event
    /// details.
    func didReceive(_ report: TelemetryReport) {
        Task {
            do {
                try fileWriter.write(report, to: fileURL)

                let data = try Data(contentsOf: fileURL)

                if /// `cloudStorage` must be successfully created from the `cloudStorageProvider`.
                    let cloudStorage = try cloudStorageProvider.makeStorage(),

                    /// The current network path status must be `.satisfied` (device is online).
                    pathMonitor.currentPath.status == .satisfied,

                    /// The `data` to be uploaded must not be empty.
                    !data.isEmpty {
                    let fileName = "\(UUID()).json"

                    cloudStorage.upload(data, fileName: fileName, contentType: .json)
                        .onComplete { [weak self] result in
                            guard let self else { return }

                            guard let error = result.failure else {
                                try? self.fileWriter.remove(at: fileURL)
                                return
                            }

                            print("❌ Upload failed with error: \(error)")
                        }
                        .resume()
                }
            } catch {
                print("Failed to process report: \(error)")
            }
        }
    }
}
