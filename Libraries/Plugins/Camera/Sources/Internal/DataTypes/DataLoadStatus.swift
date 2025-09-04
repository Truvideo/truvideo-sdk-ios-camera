//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the different statuses of an asynchronous data load operation.
///
/// `DataLoadStatus` is commonly used to track the progress of a data-loading operation,
/// such as fetching API data, refreshing content, or handling failures. It provides
/// clear states for managing UI updates and error handling accordingly.
public enum DataLoadStatus: Sendable {
    /// The initial state before any data-loading operation begins.
    case initial

    /// Indicates that the data-loading operation has failed.
    case failure

    /// Indicates that data is currently being loaded asynchronously.
    ///
    /// This state is used to show loading indicators while waiting for data retrieval.
    case loading

    /// Indicates that a refresh operation is in progress.
    ///
    /// Typically used in pull-to-refresh actions where data is being refreshed
    /// without changing the initial dataset.
    case refreshing

    /// Indicates that the data-loading operation has completed successfully.
    ///
    /// This state confirms that the requested data has been retrieved without errors.
    case success
}
