//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CloudStorage
import CloudStorageTesting
import Foundation
import Telemetry
import Network
import Testing
import TruvideoSdkTesting
import Utilities
import UtilitiesTesting

@testable import TruvideoSdk

struct UploadProcessorTests {
    // MARK: - Private Properties
        
    private let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
        UUID().uuidString,
        isDirectory: true
    )

    private let report = TelemetryReport(
        events: [
            TelemetryReport.Event(name: "Event1", severity: .info, source: "unit-test")
        ],
        context: Context(
            device: Context.Device(
                battery: Context.Device.Battery(
                    isLowPowerMode: false,
                    level: 0.85,
                    state: "charging"
                ),
                cpuArchitecture: "arm64",
                disk: Context.Device.Disk(free: 128_000_000_000, total: 256_000_000_000),
                manufacturer: "Apple",
                memory: Context.Device.Memory(free: 4_000_000_000, total: 8_000_000_000),
                model: "MacBookPro18,3",
                processorCount: 10,
                thermalState: "nominal",
                uptimeSeconds: 3600
            ),
            osInfo: Context.OsInfo(name: "macOS", version: "14.5"),
            sdks: ["TelemetrySDK": "1.0.0", "Networking": "2.3.1"]
        ),
        session: Session(installationId: UUID())
    )
        
    // MARK: - Tests
    
    @Test
    func testThatDidReceiveReportIsWrittenToFileBeforeUpload() async throws {
        // Given
        let fileWriter = FileWriterMock()
        let cloudStorage = CloudStorageMock()
        let cloudStorageProvider = CloudStorageProviderMock()
        let uploadDataTask = UploadDataTaskMock()
        let sut = UploadProcessor(cloudStorageProvider: cloudStorageProvider)
        
        // When
        cloudStorageProvider.cloudStorage = cloudStorage
        cloudStorage.uploadDataTask = uploadDataTask
        fileWriter.writtenReport = report
        
        sut.didReceive(report)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(cloudStorageProvider.makeStorageCallCount == 1)
        #expect(fileWriter.writtenReport != nil)
        #expect(cloudStorageProvider.cloudStorage is CloudStorageMock)
    }

    @Test
    func testThatDidReceiveReportReturnsWhenCloudStorageIsNil() async throws {
        // Given
        let cloudStorageProvider = CloudStorageProviderMock()
        let sut = UploadProcessor(cloudStorageProvider: cloudStorageProvider)
        
        // When
        sut.didReceive(report)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(cloudStorageProvider.makeStorageCallCount == 1)
        #expect(cloudStorageProvider.cloudStorage == nil)
    }

    @Test
    func testThatDidReceiveReportUploadsAndRemoveLocalFile() async throws {
        // Given
        let cloudStorage = CloudStorageMock()
        let cloudStorageProvider = CloudStorageProviderMock()
        let expectedURL = URL(string: "https://example.com/file.json")!
        let pathMonitor = NetworkPathMonitorMock()
        let uploadDataTask = UploadDataTaskMock()
        let sut = UploadProcessor(
            cloudStorageProvider: cloudStorageProvider,
            pathMonitor: pathMonitor,
            storageURL: tempURL
        )
        
        // When
        try FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true)
        
        cloudStorageProvider.cloudStorage = cloudStorage
        cloudStorage.uploadDataTask = uploadDataTask
        
        sut.didReceive(report)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        cloudStorage.uploadDataTask?.complete(with: .success(expectedURL))
        
        // Then
        #expect(cloudStorage.uploadDataTask?.resumeCallCount == 1)
    }
    
    @Test
    func testThatDidReceiveReportShouldFailsOnTaskError() async throws {
        // Given
        let cloudStorage = CloudStorageMock()
        let cloudStorageProvider = CloudStorageProviderMock()
        let pathMonitor = NetworkPathMonitorMock()
        let uploadTask = UploadDataTaskMock()
        let sut = UploadProcessor(
            cloudStorageProvider: cloudStorageProvider,
            pathMonitor: pathMonitor,
            storageURL: tempURL
        )
        let fileURL = tempURL.appendingPathComponent("report.json")
        
        // When
        try FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true)
        
        cloudStorageProvider.cloudStorage = cloudStorage
        cloudStorage.uploadDataTask = uploadTask
        
        sut.didReceive(report)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        cloudStorage.uploadDataTask?.onCompleteHandler?(.failure(UtilityError(kind: .unknown)))
        
        // Then
        #expect(cloudStorage.uploadDataTask?.resumeCallCount == 1)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test
    func testThatDidReceiveReportDoesNotUploadWhenNetworkUnsatisfied() async throws {
        // Given
        let cloudStorage = CloudStorageMock()
        let cloudStorageProvider = CloudStorageProviderMock()
        let networkPath = NetworkPathMock(status: .unsatisfied)
        let pathMonitor = NetworkPathMonitorMock(initialPath: networkPath)
        let sut = UploadProcessor(
            cloudStorageProvider: cloudStorageProvider,
            pathMonitor: pathMonitor,
            storageURL: tempURL
        )

        // When
        cloudStorageProvider.cloudStorage = cloudStorage
        sut.didReceive(report)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(cloudStorage.uploadDataTask == nil)
    }
}
