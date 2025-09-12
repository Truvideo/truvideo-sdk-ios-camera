//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CloudStorage
import Foundation
import Testing
import TruVideoApi
import Utilities

@testable import TruvideoSdk

struct CloudStorageProviderTests {
    
    // MARK: - Private Properties
    
    private let deviceSettings = DeviceSetting(
        isAutoPlayEnabled: true,
        isNoseCancellingEnabled: false,
        s3Configuration: DeviceSetting.S3Configuration(
            bucketName: "test-bucket",
            bucketForLogs: "test-logs-bucket",
            bucketForMedia: "test-media-bucket",
            identityId: "test-identity-id",
            identityPoolId: "test-pool-id",
            newBucketFolderForLogs: "logs-folder",
            newBucketFolderForMedia: "media-folder",
            region: "us-west-2"
        )
    )
    
    // MARK: - Tests
    
    @Test
    func testThatMakeStorageReturnsNilWhenNoDeviceSetting() async throws {
        // Given
        let sut = S3CloudStorageProvider()
        
        // When
        let storage = try sut.makeStorage()
        
        // Then
        #expect(storage == nil)
        #expect(sut.deviceSetting == nil)
    }
    
    @Test
    func testThatMakeStorageShouldSucceed() async throws {
        // Given
        let sut = S3CloudStorageProvider()
        
        // When
        sut.deviceSetting = deviceSettings
        
        let storage = try sut.makeStorage()
        
        // Then
        #expect(sut.deviceSetting != nil)
        #expect(storage is S3CloudStorage)
    }
}
