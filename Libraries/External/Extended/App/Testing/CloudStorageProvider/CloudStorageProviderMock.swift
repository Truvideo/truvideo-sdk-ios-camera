//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CloudStorageKit
import TruVideoApi
import Utilities

@testable import TruvideoSdk

/// A mock implementation of `CloudStorageProvider` for use in unit tests.
public final class CloudStorageProviderMock: CloudStorageProvider {
    // MARK: - Properties

    /// The device-specific configuration associated with this cloud storage provider.
    public var deviceSetting: DeviceSetting?
    
    /// The error to throw when `makeStorage()` is called.
    private var error: UtilityError?

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
    public func makeStorage() throws(UtilityError) -> (any CloudStorage)? {
        makeStorageCallCount += 1

        if let error {
            throw error
        }

        return cloudStorage
    }
}
