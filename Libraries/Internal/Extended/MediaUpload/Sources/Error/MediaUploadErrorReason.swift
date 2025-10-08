//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the signer.
    ///
    /// The `MediaUploadErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct MediaUploadErrorReason: Sendable {
        /// Error indicating that the multipart media upload could not be completed.
        ///
        /// This error occurs when the `complete` request for an upload session fails.
        ///
        /// Use this error to detect and handle failures when attempting to complete
        /// an upload and produce the final `Media` object.
        public static let completeUploadFailed = ErrorReason(rawValue: "COMPLETE_UPLOAD_FAILED")

        /// Error indicating that an uploaded part could not be registered for a multipart session.
        ///
        /// This error occurs when the client attempts to register a chunk
        /// (identified by its `partNumber` and `eTag`) under a given `uploadId`
        /// and the request fails.
        ///
        /// Use this error to detect and handle failures when confirming that
        /// uploaded chunks are ready to be assembled during `complete(...)`.
        public static let partRegistrationFailed = ErrorReason(rawValue: "PART_REGISTRATION_FAILED")

        /// Error indicating that upload parts could not be retrieved for a multipart session.
        ///
        /// This error occurs when the attempt to fetch presigned URLs for upload parts fails.
        ///
        /// Use this error to detect and handle failures when progressively retrieving
        /// upload parts for streaming or multipart uploads.
        public static let retrieveUploadPartsFailed = ErrorReason(rawValue: "RETRIEVE_UPLOAD_PARTS_FAILED")

        /// Error indicating that the initialization of a multipart media upload has failed.
        ///
        /// This error occurs when the TruVideo API cannot create a new upload session.
        /// Possible causes include invalid request parameters (`amountOfParts`, `fileType`),
        /// network connectivity issues, or an invalid authentication session.
        public static let uploadInitializationFailed = ErrorReason(rawValue: "UploadInitializationFailed")
    }
}
