//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Security

/// A protocol describing the API used to evaluate server trusts.
public protocol ServerTrustEvaluator: Sendable {
    /// Evaluates the given `SecTrust` value for the given `host`.
    ///
    /// - Parameters:
    ///   - trust: The `SecTrust` value to evaluate.
    ///   - host:  The host for which to evaluate the `SecTrust` value.
    /// - Returns: A `Bool` indicating whether the evaluator considers the `SecTrust` value valid for `host`.
    func evaluate(_ trust: SecTrust, forHost host: String) throws
}

/// A protocol that defines a provider for retrieving `ServerTrustEvaluator` instances.
///
/// Implementing types should provide a mechanism to retrieve an appropriate
/// `ServerTrustEvaluator` for a given host, allowing for customizable
/// SSL/TLS certificate validation strategies.
///
/// ### Example Usage:
/// ```swift
/// let provider: ServerTrustEvaluatorProvider = DefaultServerTrustEvaluatorProvider(evaluators: ["example.com": CustomTrustEvaluator()])
/// let evaluator = provider.evaluator(forHost: "example.com")
/// ```
public protocol ServerTrustEvaluatorProvider: Sendable {
    /// Retrieves a `ServerTrustEvaluator` instance for the specified host.
    ///
    /// - Parameter host: The host for which to retrieve the evaluator.
    /// - Returns: An optional `ServerTrustEvaluator` instance for the given host, or `nil` if no evaluator is found.
    func evaluator(forHost host: String) -> (any ServerTrustEvaluator)?
}

/// A default implementation of `ServerTrustEvaluatorProvider`.
///
/// This class provides a basic key-value mapping mechanism to associate hosts
/// with their corresponding `ServerTrustEvaluator` instances.
public final class DefaultServerTrustEvaluatorProvider: ServerTrustEvaluatorProvider {
    // MARK: - Private Properties

    /// A dictionary mapping hostnames to their respective `ServerTrustEvaluator` instances.
    private let evaluators: [String: ServerTrustEvaluator]

    // MARK: - Initializer

    /// Creates a new `DefaultServerTrustEvaluatorProvider` with a dictionary of evaluators.
    ///
    /// - Parameter evaluators: A dictionary mapping hostnames to `ServerTrustEvaluator` instances.
    public init(evaluators: [String: ServerTrustEvaluator]) {
        self.evaluators = evaluators
    }

    // MARK: - ServerTrustEvaluatorProvider

    /// Retrieves a `ServerTrustEvaluator` instance for the specified host.
    ///
    /// - Parameter host: The host for which to retrieve the evaluator.
    /// - Returns: An optional `ServerTrustEvaluator` instance if available, otherwise `nil`.
    public func evaluator(forHost host: String) -> (any ServerTrustEvaluator)? {
        evaluators[host]
    }
}
