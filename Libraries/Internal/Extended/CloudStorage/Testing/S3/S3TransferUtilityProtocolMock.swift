//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Utilities

@testable import CloudStorageKit

/// A mock implementation of `S3TransferUtilityProtocol` used for unit testing.
///
/// This class captures the parameters passed to the `uploadData` method, and allows
/// tests to inspect those values later. It also stores the provided completion handler
/// so that tests can manually simulate success or failure scenarios.
public final class S3TransferUtilityProtocolMock: S3TransferUtilityProtocol {
    // MARK: - Properties

    /// The data provided in the `uploadData` call.
    public private(set) var data: Data?

    /// The S3 bucket name provided in the `uploadData` call.
    public private(set) var bucket: String?

    /// The object key (path) provided in the `uploadData` call.
    public private(set) var key: String?

    /// The content type of the uploaded object.
    public private(set) var contentType: String?

    /// The upload expression used in the call (contains configuration and progress blocks).
    public private(set) var expression: AWSS3TransferUtilityUploadExpression?

    /// The completion handler provided in the `uploadData` call.
    public var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?

    /// The task result that will be returned when `uploadData` is invoked.
    public var result: AWSTask<AWSS3TransferUtilityUploadTask>?

    // MARK: - Initializer

    public init() {}

    // MARK: - S3TransferUtilityProtocol

    /// Simulates the S3 upload operation.
    ///
    /// Instead of actually uploading to AWS S3, this method:
    /// - Stores the arguments for later inspection.
    /// - Captures the provided completion handler for manual triggering.
    /// - Returns the preconfigured `result` task (or crashes if unset).
    ///
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - bucket: The destination S3 bucket.
    ///   - key: The object key (path) within the bucket.
    ///   - contentType: The MIME type of the object being uploaded.
    ///   - expression: Upload expression with configuration options.
    ///   - completionHandler: Callback invoked upon upload completion or error.
    /// - Returns: The mocked `AWSTask` representing the upload task.
    public func uploadData(
        _ data: Data,
        bucket: String,
        key: String,
        contentType: String,
        expression: AWSS3TransferUtilityUploadExpression?,
        completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    ) -> AWSTask<AWSS3TransferUtilityUploadTask> {
        self.data = data
        self.bucket = bucket
        self.key = key
        self.expression = expression
        self.completionHandler = completionHandler

        return result!
    }
}
