//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
internal import InternalUtilities
import Networking
import Utilities

/// A protocol that defines the interface for managing multipart media uploads with the TruVideo API.
///
/// This protocol provides a standardized way to initialize and finalize multipart
/// uploads of media files. It abstracts the details of interacting with the upload
/// endpoints, ensuring a consistent flow for uploading large files in multiple parts.
public protocol UploadResource: Sendable {
    /// Completes a multipart upload session.
    ///
    /// Finalizes the upload associated with `uploadId`. All previously uploaded
    /// chunks are validated and assembled into the final media object. If any
    /// required part is missing or invalid, completion will fail.
    ///
    /// # Behavior
    /// - Uses the server-side record of uploaded parts; no part list or ETags
    ///   need to be provided by the client.
    /// - Idempotent: calling `complete` more than once for the same `uploadId`
    ///   is safe; subsequent calls will return the final state.
    /// - The resulting `Media` may undergo post-processing (e.g., transcoding);
    ///   consult the returned status to track readiness.
    ///
    /// # Prerequisites
    /// - A multipart session was created via `start`.
    /// - All intended parts have been uploaded using presigned URLs obtained with
    ///   `retrieve(...)`.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the multipart upload session.
    ///   - parts: The list of uploaded parts to commit (each with `partNumber` and `eTag`).
    /// - Returns: A `Media` representing the finalized media resource.
    /// - Throws: `UtilityError` if the request fails, the session is incomplete, or the server rejects the upload.
    func complete(for uploadId: String, withParts parts: [UploadPart]) async throws(UtilityError)

    /// Registers a previously uploaded part for the multipart session.
    ///
    /// Associates the given `partNumber` and `eTag` with the specified `uploadId`.
    /// The backend stores this information and uses it later during `complete(...)`
    /// to assemble the final media file.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the multipart upload session.
    ///   - part: The uploaded part descriptor containing `partNumber` (1-based) and its `eTag`.
    /// - Throws: `UtilityError` if the request fails or the part cannot be registered.
    func register(for uploadId: String, withPart part: UploadPart) async throws(UtilityError) -> UploadPartStatus

    /// Retrieves presigned URLs for the next set of parts in a multipart upload session.
    ///
    /// Obtains a collection of parts to be uploaded next in a multipart transfer.
    /// Each part includes its sequence number and a presigned URL used to PUT the
    /// corresponding chunk directly to storage.
    ///
    /// Each retrieved part includes its `partNumber` and the corresponding `uploadPresignedUrl`.
    /// Once uploaded, you must keep track of the `{ partNumber, eTag }` pairs and
    /// send them back when finalizing the session.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the upload session, returned by `start`.
    ///   - count: The number of parts to request in this batch (valid range: 1...10_000).
    /// - Returns: A batch of upload parts, each containing a presigned URL and its sequence number.
    /// - Throws: `UtilityError` if the request fails, the parameters are invalid or the server response cannot be
    /// decoded.
    func retrieve(for uploadId: String, count: Int) async throws(UtilityError) -> [Part]

    /// Initializes a multipart media upload session with the TruVideo API.
    ///
    /// Starts a new upload session and returns an `UploadSession` containing only the
    /// identifiers required to continue the transfer. Presigned URLs are **not** included
    /// here; they are fetched progressively as needed using `retrieve(...)` during
    /// the upload workflow. Once all chunks have been uploaded, complete the process
    /// by calling `complete(...)`.
    ///
    /// # Behavior
    /// - Returns unique identifiers for the session (e.g., `uploadId`, `mediaId`).
    /// - Does **not** return presigned URLs; those are obtained on demand.
    /// - Designed for streaming and incremental uploads (mobile-friendly).
    ///
    /// - Parameters:
    ///   - fileType: The media file type (e.g., `.mp4`, `.jpg`).
    /// - Returns: An `UploadSession` containing the identifiers needed to proceed (no URLs).
    /// - Throws: `UtilityError` if the request fails, the session cannot be created, or parameters are invalid.
    func start(for fileType: FileType) async throws(UtilityError) -> UploadSession
}

/// A concrete implementation of the `UploadResource` protocol.
///
/// This struct provides the actual implementation for initializing and finalizing
/// multipart media uploads with the TruVideo API. It uses dependency injection to
/// access the API environment, network session, and session manager for authentication.
public struct UploadResourceImpl: UploadResource {
    // MARK: - Dependencies

    @Dependency(\.environment)
    private var environment: Environment

    @Dependency(\.truVideoSession)
    private var session: any Session

    // MARK: - Initializer

    /// Creates a new instance of the `UploadResourceImpl`.
    public init() {}

    // MARK: - UploadResource

    /// Completes a multipart upload session.
    ///
    /// Finalizes the upload associated with `uploadId`. All previously uploaded
    /// chunks are validated and assembled into the final media object. If any
    /// required part is missing or invalid, completion will fail.
    ///
    /// # Behavior
    /// - Uses the server-side record of uploaded parts; no part list or ETags
    ///   need to be provided by the client.
    /// - Idempotent: calling `complete` more than once for the same `uploadId`
    ///   is safe; subsequent calls will return the final state.
    /// - The resulting `Media` may undergo post-processing (e.g., transcoding);
    ///   consult the returned status to track readiness.
    ///
    /// # Prerequisites
    /// - A multipart session was created via `start`.
    /// - All intended parts have been uploaded using presigned URLs obtained with
    ///   `retrieve(...)`.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the multipart upload session.
    ///   - parts: The list of uploaded parts to commit (each with `partNumber` and `eTag`).
    /// - Throws: `UtilityError` if the request fails, the session is incomplete, or the server rejects the upload.
    public func complete(for uploadId: String, withParts parts: [UploadPart]) async throws(UtilityError) {
        do {
            let parameters = [
                "parts": parts.map { part in
                    [
                        "etag": part.eTag,
                        "partNumber": part.partNumber
                    ]
                }
            ]

            _ = try await session.request(
                environment.baseURL.appending("/upload/\(uploadId)/complete/stream"),
                method: .post,
                parameters: parameters,
                encoder: .json
            )
            .validate()
            .serializing(Empty.self)
            .result
            .get()
        } catch {
            throw UtilityError(kind: .MediaUploadErrorReason.completeUploadFailed, underlyingError: error)
        }
    }

    /// Registers a previously uploaded part for the multipart session.
    ///
    /// Associates the given `partNumber` and `eTag` with the specified `uploadId`.
    /// The backend stores this information and uses it later during `complete(...)`
    /// to assemble the final media file.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the multipart upload session.
    ///   - part: The uploaded part descriptor containing `partNumber` (1-based) and its `eTag`.
    /// - Throws: `UtilityError` if the request fails or the part cannot be registered.
    public func register(
        for uploadId: String,
        withPart part: UploadPart
    ) async throws(UtilityError) -> UploadPartStatus {
        do {
            return try await session.request(
                environment.baseURL.appending("/upload/\(uploadId)/part"),
                method: .post,
                parameters: [
                    "partNumber": part.partNumber,
                    "etag": part.eTag
                ],
                encoder: .json
            )
            .validate()
            .serializing(UploadPartStatus.self)
            .result
            .get()
        } catch {
            throw UtilityError(kind: .MediaUploadErrorReason.partRegistrationFailed, underlyingError: error)
        }
    }

    /// Retrieves presigned URLs for the next set of parts in a multipart upload session.
    ///
    /// Obtains a collection of parts to be uploaded next in a multipart transfer.
    /// Each part includes its sequence number and a presigned URL used to PUT the
    /// corresponding chunk directly to storage.
    ///
    /// Each retrieved part includes its `partNumber` and the corresponding `uploadPresignedUrl`.
    /// Once uploaded, you must keep track of the `{ partNumber, eTag }` pairs and
    /// send them back when finalizing the session.
    ///
    /// - Parameters:
    ///   - uploadId: The unique identifier of the upload session, returned by `start`.
    ///   - count: The number of parts to request in this batch (valid range: 1...10_000).
    /// - Returns: A batch of upload parts, each containing a presigned URL and its sequence number.
    /// - Throws: `UtilityError` if the request fails, the parameters are invalid or the server response cannot be
    /// decoded.
    public func retrieve(for uploadId: String, count: Int) async throws(UtilityError) -> [Part] {
        do {
            return try await session.request(
                environment.baseURL.appending("/upload/\(uploadId)/parts"),
                method: .get,
                parameters: [
                    "count": count
                ],
                encoder: .url
            )
            .validate(RequestValidator.validate)
            .serializing(UploadPartResponse.self)
            .result
            .get()
            .parts
        } catch {
            throw UtilityError(kind: .MediaUploadErrorReason.retrieveUploadPartsFailed, underlyingError: error)
        }
    }

    /// Initializes a multipart media upload session with the TruVideo API.
    ///
    /// Starts a new upload session and returns a `UploadSession` containing
    /// the unique `uploadId` and a list of presigned URLs, one for each file part.
    /// Each presigned URL must be used to upload the corresponding chunk directly
    /// to the storage service via HTTP PUT. After all parts are uploaded, the
    /// session must be finalized with `finalize`.
    ///
    /// - Parameter fileType: The type of the media file being uploaded (e.g., `.mp4`, `.jpg`).
    /// - Returns: A `UploadSession` containing the `uploadId` and the presigned URLs required to upload each part.
    /// - Throws: `UtilityError` if the request fails, the session cannot be created, or the provided parameters are
    /// invalid.
    public func start(for fileType: FileType) async throws(UtilityError) -> UploadSession {
        do {
            return try await session.request(
                environment.baseURL.appending("/upload/start/stream"),
                method: .post,
                parameters: [
                    "media": [
                        "fileType": fileType.rawValue
                    ]
                ],
                encoder: .json
            )
            .validate(RequestValidator.validate)
            .serializing(UploadSession.self)
            .result
            .get()
        } catch {
            throw UtilityError(kind: .MediaUploadErrorReason.uploadInitializationFailed, underlyingError: error)
        }
    }
}
