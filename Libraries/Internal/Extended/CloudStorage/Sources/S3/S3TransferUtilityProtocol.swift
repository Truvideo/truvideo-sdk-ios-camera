//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3

/// `S3TransferUtilityProtocol` defines an abstraction layer for uploading data to Amazon S3
/// using `AWSS3TransferUtility`. This protocol allows you to decouple your code from the
/// concrete implementation and makes testing (e.g., with mocks or stubs) easier.
protocol S3TransferUtilityProtocol {
    /// Uploads raw `Data` to an S3 bucket.
    ///
    /// - Parameters:
    ///   - data: The binary data to be uploaded.
    ///   - buckect: The target S3 bucket name. *(Note: probably intended as `bucket` — typo in the name)*.
    ///   - key: The object key under which the data will be stored in S3.
    ///   - contentType: The MIME type of the uploaded data (e.g., `"image/png"`).
    ///   - expression: An `AWSS3TransferUtilityUploadExpression` that allows you to configure
    ///     progress callbacks and request headers.
    ///   - completionHandler: A closure invoked upon completion of the upload.
    ///     Provides the upload task and an optional error if the operation fails.
    ///
    /// - Returns: An `AWSTask` representing the asynchronous upload operation,
    ///   which resolves to an `AWSS3TransferUtilityUploadTask`.
    func uploadData(
        _ data: Data,
        bucket: String,
        key: String,
        contentType: String,
        expression: AWSS3TransferUtilityUploadExpression?,
        completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    )
        -> AWSTask<AWSS3TransferUtilityUploadTask>
}

extension AWSS3TransferUtility: S3TransferUtilityProtocol {}
