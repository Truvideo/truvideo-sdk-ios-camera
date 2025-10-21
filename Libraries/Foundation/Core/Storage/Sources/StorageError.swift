//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// An error type that represents failures that can occur during storage operations.
///
/// `StorageError` provides a unified error handling mechanism for all storage-related
/// operations across different storage implementations (FileSystem, InMemory, UserDefaults).
/// Each error case wraps the underlying error that caused the failure, allowing for
/// detailed error analysis and debugging.
public enum StorageError: LocalizedError {
    /// Indicates that clearing all data from storage failed.
    ///
    /// This error occurs when attempting to remove all stored key-value pairs
    /// from the storage system. Common causes include:
    /// - Insufficient permissions to delete files
    /// - File system corruption
    /// - Storage system is read-only
    ///
    /// - Parameter error: The underlying error that caused the clear operation to fail.
    case clearFailed(Error)

    /// Indicates that deleting a specific value from storage failed.
    ///
    /// This error occurs when attempting to remove a specific key-value pair
    /// from storage. Common causes include:
    /// - The key doesn't exist (usually not an error)
    /// - File system permission issues
    /// - Storage system corruption
    ///
    /// - Parameter error: The underlying error that caused the delete operation to fail.
    case deleteFailed(Error)

    /// Indicates that reading a value from storage failed.
    ///
    /// This error occurs when attempting to retrieve a value from storage.
    /// Common causes include:
    /// - Data corruption during serialization
    /// - File system read errors
    /// - Memory constraints
    /// - JSON decoding failures
    ///
    /// - Parameter error: The underlying error that caused the read operation to fail.
    case readFailed(Error)

    /// Indicates that writing a value to storage failed.
    ///
    /// This error occurs when attempting to store a value in the storage system.
    /// Common causes include:
    /// - Insufficient disk space
    /// - File system permission issues
    /// - JSON encoding failures
    /// - Storage quota exceeded (UserDefaults)
    /// - Memory constraints (InMemory storage)
    ///
    /// - Parameter error: The underlying error that caused the write operation to fail.
    case writeFailed(Error)

    // MARK: - LocalizedError

    /// A localized message describing what error occurred.
    ///
    /// This property provides a user-friendly description of the storage error.
    /// It delegates to `failureReason` to provide consistent error messaging.
    public var errorDescription: String? {
        failureReason
    }

    /// A localized message describing the reason for the failure.
    ///
    /// This property extracts the localized description from the underlying error
    /// that caused the storage operation to fail. This provides detailed information
    /// about what went wrong during the storage operation.
    public var failureReason: String? {
        switch self {
        case let .clearFailed(error):
            "Failed to clear storage: \(error.localizedDescription)"

        case let .deleteFailed(error):
            "Failed to delete value from storage: \(error.localizedDescription)"

        case let .readFailed(error):
            "Failed to read value from storage: \(error.localizedDescription)"

        case let .writeFailed(error):
            "Failed to write value to storage: \(error.localizedDescription)"
        }
    }
}
