//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// `DataRequest` subclass which handles `Data` upload from memory, file, or stream using `URLSessionUploadTask`.
public class HTTPURLUploadRequest: HTTPURLDataRequest, UploadRequest, @unchecked Sendable {
    // MARK: - Properties

    /// `FileManager` used to perform cleanup tasks, including the removal of multipart form encoded payloads written to
    /// disk.
    public let fileManager: FileManager?

    /// `Uploadable` value used by the instance.
    public var uploadable: Uploadable?

    /// The `UploadableConvertible` value used to produce the `Uploadable` value for this instance.
    public let uploadableBuilder: any UploadableBuilder

    // MARK: - Types

    /// Type describing the origin of the upload, whether `Data`, file, or stream.
    public enum Uploadable: @unchecked Sendable {
        /// Upload from the provided `Data` value.
        case data(Data)

        /// Upload from the provided file `URL`, as well as a `Bool` determining whether the source file should be
        /// automatically removed once uploaded.
        case file(URL, shouldRemove: Bool)

        /// Upload from the provided `InputStream`.
        case stream(InputStream)
    }

    // MARK: - Initializer

    /// Initializes a new request.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the request.
    ///   - requestBuilder: The builder used to construct the request.
    ///   - delegate: The delegate responsible for handling retries.
    ///   - fileManager: `FileManager` used to perform cleanup tasks, including the removal of multipart form encoded
    /// payloads written to disk.
    ///   - middleware: An optional request interceptor for intercepting the request.
    ///   - monitor: An optional request monitor.
    ///   - queue: The dispatch queue for processing tasks.
    init(
        id: UUID = UUID(),
        uploadBuilder: UploadRequestBuilder,
        delegate: HTTPURLRequestDelegate?,
        fileManager: FileManager? = nil,
        middleware: RequestMiddleware?,
        monitor: Monitor?,
        queue: DispatchQueue
    ) {
        self.fileManager = fileManager
        self.uploadableBuilder = uploadBuilder

        super.init(
            id: id,
            requestBuilder: uploadBuilder,
            cache: nil,
            cachePolicy: .reloadIgnoringLocalCacheData,
            delegate: delegate,
            middleware: middleware,
            monitor: monitor,
            queue: queue
        )
    }

    // MARK: - LifeCycle methods

    /// Called when the `Uploadable` value has been created from the `UploadConvertible`.
    ///
    /// - Parameter uploadable: The `Uploadable` that was created.
    func didCreateUploadable(_ uploadable: Uploadable) {
        self.uploadable = uploadable

        monitor?.request(self, didCreateUploadable: uploadable)
    }

    /// Called when the `Uploadable` value could not be created.
    ///
    ///
    /// - Parameter error: `NetworkingError` produced by the failure.
    func didFailToCreateUploadable(with error: NetworkingError) {
        self.error = error

        monitor?.request(self, didFailToCreateUploadableWithError: error)
        retryOrFinish(error: error)
    }

    // MARK: - Overriden methods

    /// Final cleanup step executed when the instance finishes response serialization.
    override func cleanup() {
        defer { super.cleanup() }

        guard
            /// The upload payload produced for this request.
            let uploadable,

            /// Ensure the payload originates from a file URL and extract its components.
            case let .file(url, shouldRemove) = uploadable,

            /// Whether remove the source file only when explicitly requested.
            shouldRemove
        else {
            return
        }

        try? fileManager?.removeItem(at: url)
    }

    /// Resets the request's state to its initial configuration.
    ///
    /// This method clears the internal state of the request by performing the following actions:
    /// 1. Sets the `error` property to `nil`, effectively clearing any previously encountered errors.
    /// 2. Resets the `state` property to `.initialized`, preparing the request for a fresh start.
    /// 3. Removes all registered response serializers from the `responseSerializers` array.
    ///
    /// This function is useful for reinitializing a request instance without creating a new object,
    /// particularly in scenarios where you want to retry a request from a clean state or reuse the same instance.
    override func reset() {
        super.reset()

        uploadable = nil
    }

    /// Called when creating a `URLSessionTask` for this `Request`. Subclasses must override.
    ///
    /// - Parameters:
    ///   - urlRequest: `URLRequest` to use to create the `URLSessionTask`.
    ///   - session: `URLSession` which creates the `URLSessionTask`.
    ///
    /// - Returns:   The `URLSessionTask` created.
    override func task(
        for urlRequest: URLRequest,
        using session: URLSession
    ) throws(NetworkingError) -> URLSessionTask {
        guard let uploadable else {
            throw NetworkingError(
                kind: .createUploadableFailed,
                failureReason: "Attempting to create a URLSessionUploadTask when Uploadable value doesn't exist."
            )
        }

        switch uploadable {
        case let .data(data):
            return session.uploadTask(with: urlRequest, from: data)

        case let .file(url, _):
            return session.uploadTask(with: urlRequest, fromFile: url)

        case .stream:
            return session.uploadTask(withStreamedRequest: urlRequest)
        }
    }
}
