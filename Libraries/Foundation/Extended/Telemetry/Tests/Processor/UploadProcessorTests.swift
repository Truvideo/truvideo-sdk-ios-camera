//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Network
import Testing

@testable import Telemetry

struct UploadProcessorTests {
    // MARK: - Private Properties
    
    private var uploader: UploaderMock!
    private var fileWriter: FileWriterMock!
    
    // MARK: - Initializer
    
    init () {
        uploader = UploaderMock()
        fileWriter = FileWriterMock()
    }

    // MARK: - Tests

    @Test
    func testThatSuccessfulReportHandling() async throws {
        await withDependencyValues { dependencies in
            // Given
            let tempURL = FileManager.default.temporaryDirectory
            let fileManager = FileManagerMock()
            let monitor = NetworkPathMonitorMock()
            let sut = UploadProcessor(fileManager: fileManager, pathMonitor: monitor, storageURL: tempURL)
            let report = TelemetryReport.mock
            
            let sampleString = "{\"name\": \"floo\"}"
            let data = sampleString.data(using: .utf8)!
            try? data.write(to: tempURL.appendingPathComponent("reports.json"))

            // When
            dependencies.uploader = uploader
            dependencies.fileWriter = fileWriter
            
            sut.didReceive(report)
            try? await Task.sleep(nanoseconds: 100_000_000)

            // Then
            #expect(fileWriter.writtenReport?.session.id == report.session.id, "Report")
            #expect(uploader.fileName == "reports.json", "Uploader should use 'reports.json' as the file name")
            #expect(uploader.data == data, "Uploader should receive the correct data")
            #expect(uploader.contentType == .json, "Uploader should use 'application/json' as the content type")
            #expect(
                fileManager.url == tempURL.appendingPathComponent("reports.json"),
                "File URL should be 'reports.json'"
            )
        }
    }

    @Test
    func testThatReportIsNotWrittenOrUploadedOnFailure() async throws {
        await withDependencyValues { dependencies in
            // Given
            let tempURL = FileManager.default.telemetryDirectory.appendingPathComponent("/\(UUID())")

            let fileManager = FileManagerMock()
            let monitor = NetworkPathMonitorMock()
            let sut = UploadProcessor(fileManager: fileManager, pathMonitor: monitor, storageURL: tempURL)
            let report = TelemetryReport.mock

            // When
            dependencies.uploader = uploader
            dependencies.fileWriter = fileWriter

            fileWriter.error = NSError(domain: "", code: 0)

            sut.didReceive(report)
            try? await Task.sleep(nanoseconds: 100_000_000)

            // Then
            #expect(fileManager.url == nil, "FileManager should not have a URL set on failure")
            #expect(uploader.fileName == nil, "Uploader should not have a fileName set on failure")
            #expect(uploader.contentType == nil, "Uploader should not have a contentType set on failure")
            #expect(uploader.data == nil, "Uploader should not have data set on failure")
            #expect(fileWriter.writtenReport == nil, "FileWriter should not have written a report on failure")
        }
    }

    @Test
    func testThatReportIsNotSavedOrUploadedWhenNetworkConnectionIsUnavailable() async throws {
        await withDependencyValues { dependencies in
            // Given
            let tempURL = FileManager.default.telemetryDirectory.appendingPathComponent("/\(UUID())")

            let fileManager = FileManagerMock()
            let monitor = NetworkPathMonitorMock()
            let sut = UploadProcessor(fileManager: fileManager, pathMonitor: monitor, storageURL: tempURL)
            let report = TelemetryReport.mock

            // When
            dependencies.uploader = uploader
            dependencies.fileWriter = fileWriter
            monitor.path = NetworkPathMock(status: .unsatisfied)

            sut.didReceive(report)
            try? await Task.sleep(nanoseconds: 100_000_000)

            // Then
            #expect(fileManager.url == nil, "FileManager should not have a URL set on failure")
            #expect(uploader.fileName == nil, "Uploader should not have a fileName set on failure")
            #expect(uploader.contentType == nil, "Uploader should not have a contentType set on failure")
            #expect(uploader.data == nil, "Uploader should not have data set on failure")
            #expect(fileWriter.writtenReport?.session.id == report.session.id, "Report")
        }
    }
}

private extension TelemetryReport {
    static let mock = TelemetryReport(
        events: [],
        context: .init(
            device: .init(
                battery: .init(isLowPowerMode: true, level: 1, state: "state"),
                cpuArchitecture: "architecture",
                disk: .init(free: 2, total: 3),
                manufacturer: "facturer",
                memory: .init(free: 4, total: 5),
                model: "model",
                processorCount: 6,
                thermalState: "thermal state",
                uptimeSeconds: 7
            ),
            osInfo: .init(name: "info name", version: "version"),
            sdks: [:]
        ),
        session: .init(installationId: UUID())
    )
}
