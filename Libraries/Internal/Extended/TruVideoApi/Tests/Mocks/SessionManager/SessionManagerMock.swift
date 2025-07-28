//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import TruVideoApi

/// A mock implementation of the `SessionManager` protocol for testing network requests.
final class SessionManagerMock: SessionManager, @unchecked Sendable {
    /// The currently stored authentication session, if any.
    ///
    /// This property provides access to the authentication session that was most recently
    /// stored. Returns `nil` if no session has been stored or if the session has been cleared.
    var currentSession: AuthSession?
    
    // MARK: - SessionManager

    /// Stores the provided authentication session.
    ///
    /// This method persists the authentication session for future use. The session
    /// will be available through the `currentSession` property until it is replaced
    /// or cleared.
    ///
    /// - Parameter session: The authentication session to store
    /// - Throws: An error if the session cannot be stored
    func set(_ session: AuthSession) throws {
        currentSession = session
    }
}
