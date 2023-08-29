//
//  DataLoad.swift
//  CameraApp
//
//  Created by Jorge on 28/08/23.
//

import Foundation

/// Represents the possibles status of any
/// async call.
enum DataLoadStatus: Equatable {
    /// Initial status.
    case initial

    /// Flags the status as failed.
    case failure

    /// Flags the status as failed with error.
    case failureWithError(String?)

    /// Whether the status is loading
    /// any async call.
    case loading

    /// Whether the status is refreshing
    /// Normally used for pull down to refresh.
    case refreshing

    /// Whether the async call has been finished
    /// succesfully.
    case success
}
