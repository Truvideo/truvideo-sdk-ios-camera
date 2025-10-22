//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import TruVideoApi

extension DeviceSetting {
    /// A mock instance of the device setting.
    public static var mock: DeviceSetting {
        DeviceSetting(
            isAutoPlayEnabled: true,
            isCameraModuleEnabled: true,
            isNoseCancellingEnabled: false,
            s3Configuration: DeviceSetting.S3Configuration(
                bucketName: "test-bucket",
                bucketForLogs: "logs",
                bucketForMedia: "media",
                identityId: "test-identity",
                identityPoolId: "test-pool",
                newBucketFolderForLogs: "new-logs",
                newBucketFolderForMedia: "new-media",
                region: "us-east-1"
            )
        )
    }
}
