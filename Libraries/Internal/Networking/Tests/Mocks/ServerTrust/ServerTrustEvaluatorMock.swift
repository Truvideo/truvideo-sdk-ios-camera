//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking
import Security

/// A protocol describing the API used to evaluate server trusts.
public class ServerTrustEvaluatorMock: ServerTrustEvaluator, @unchecked Sendable {
    // MARK: - Public Properties
    
    /// The number of times that the evaluate function was called.
    public private(set) var evaluateCallCount = 0
    
    /// The associated error.
    public var error: Error?
    
    // MARK: - Initializer
    
    /// Creates a new instance of the `ServerTrustEvaluatorMock`.
    public init() {}
    
    // MARK: - ServerTrustEvaluator
    
    /// Evaluates the given `SecTrust` value for the given `host`.
    ///
    /// - Parameters:
    ///   - trust: The `SecTrust` value to evaluate.
    ///   - host:  The host for which to evaluate the `SecTrust` value.
    /// - Returns: A `Bool` indicating whether the evaluator considers the `SecTrust` value valid for `host`.
    public func evaluate(_ trust: SecTrust, forHost host: String) throws {
        evaluateCallCount += 1
        
        guard let error else { return }
        
        throw error
    }
}
