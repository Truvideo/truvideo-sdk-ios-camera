//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network

/// A protocol that defines the behavior of a network path monitor, which tracks changes in the network connection path.
///
/// The `NetworPathkMonitor` protocol defines methods and properties to start monitoring network changes,
/// handle path updates when the network status changes, and cancel monitoring. The conforming types
/// should provide the ability to monitor network paths and handle updates asynchronously on a specified queue.
public protocol NetworkPathMonitor: AnyObject {
    associatedtype Path: NetworkPath

    /// Access the current network path tracked by the monitor
    var currentPath: Path { get }

    /// Set a block to be called when the network path changes. pathUpdateHandler will not be called until `start` is
    /// called.
    var pathUpdateHandler: (@Sendable (_ newPath: Path) -> Void)? { get set }

    /// Cancel the path monitor, after which point no more path updates will
    /// be delivered.
    func cancel()

    /// Start the path monitor and set a queue on which path updates
    /// will be delivered.
    ///
    /// - Parameter queue: The queue where the updates will be delivered.
    func start(queue: DispatchQueue)
}

extension NWPath: NetworkPath {}
extension NWPathMonitor: NetworkPathMonitor {}
extension NetworkPathMonitor where Path == NWPath {}
