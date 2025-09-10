//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the signer.
    ///
    /// The `CloudStorageErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct CloudStorageErrorReason: Sendable {
        /// Indicates that the cloud storage system failed to initialize properly.
        ///
        /// This error reason is thrown when the cloud storage service cannot be
        /// initialized due to configuration issues, missing credentials, network
        /// connectivity problems, or other initialization failures. The error
        /// typically occurs during the setup phase of cloud storage operations
        /// and prevents any subsequent storage operations from being performed.
        /// Check the underlying error details and cloud storage configuration
        /// to resolve this initialization failure.
        public static let cloudStorageInitializationFailed = ErrorReason(
            rawValue: "CLOUD_STORAGE_INITIALIZATION_FAILED"
        )

        /// Error indicating that the request was explicitly cancelled by the user or system.
        ///
        /// This error occurs when the upload operation is intentionally stopped
        /// before completion, either due to a user action or an explicit programmatic
        /// call to cancel the request.
        public static let explicitlyCancelled = ErrorReason(rawValue: "TASK_EXPLICITLY_CANCELLED")

        /// Error indicating that the upload operation has failed.
        ///
        /// This error occurs when the AWS S3 Transfer Utility is unable to complete
        /// the upload operation successfully.
        public static let failedToUploadData = ErrorReason(rawValue: "FAILED_TO_UPLOAD_DATA")

        /// Error indicating that the ETag header was missing in the server response.
        ///
        /// This error occurs when the upload operation completes, but the expected
        /// ETag header (used to validate data integrity of the uploaded object)
        /// is not included in the server response. Without the ETag, the application
        /// cannot guarantee that the uploaded data was correctly received and stored
        /// in the cloud storage.
        public static let missingETag = ErrorReason(rawValue: "MISSING_ETAG")

        /// Error indicating that the upload completed but no resource URL was provided.
        ///
        /// This error occurs when the AWS S3 Transfer Utility successfully finishes
        /// the upload operation, but the expected URL pointing to the uploaded object
        /// is missing from the response. Without this URL, the uploaded resource
        /// cannot be accessed or referenced, leaving the operation incomplete from
        /// the application's perspective.
        public static let missingUploadURL = ErrorReason(rawValue: "MISSING_UPLOAD_URL")

        /// Error indicating that the upload task could not be created.
        ///
        /// This error occurs when the AWS S3 Transfer Utility fails to initialize
        /// the upload task, possibly due to invalid parameters, missing configuration,
        /// or connectivity issues before the upload starts.
        public static let uploadTaskCreationFailed = ErrorReason(rawValue: "UPLOAD_TASK_CREATION_FAILED")
    }
}
