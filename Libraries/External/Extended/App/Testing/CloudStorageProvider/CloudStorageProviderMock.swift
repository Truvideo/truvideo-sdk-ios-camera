//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CloudStorageKit
import Utilities

@testable import TruvideoSdk

/// A mock implementation of `CloudStorageProvider` for use in unit tests.
public final class CloudStorageProviderMock: CloudStorageProvider {
    // MARK: - Properties

    /// The error to throw when `makeStorage()` is called.
    private var error: TruVideoSdkError?

    /// The number of times `makeStorage()` has been invoked.
    public private(set) var makeStorageCallCount = 0

    /// The storage instance to be returned by `makeStorage()`.
    public var cloudStorage: (any CloudStorage)?

    // MARK: - Initializer

    /// Creates a new instance of the `CloudStorageProvider`.
    public init() {}

    // MARK: - CloudStorageProvider

    /// Returns the injected `cloudStorage` instance.
    ///
    /// - Throws: `TruVideoSdkError` if no storage has been set.
    /// - Returns: The injected `CloudStorage` instance.
    public func makeStorage() throws(TruVideoSdkError) -> (any CloudStorage)? {
        makeStorageCallCount += 1

        if let error = error {
            throw error
        }

        return cloudStorage
    }
}
