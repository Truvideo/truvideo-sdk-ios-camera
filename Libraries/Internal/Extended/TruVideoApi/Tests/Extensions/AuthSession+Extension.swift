//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import TruVideoApi

extension AuthSession {
    /// Returns a mock instance `AuthSession`.
    static var mock: AuthSession {
        AuthSession(
            apiKey: "test-api-key",
            authToken: AuthToken(id: UUID(), accessToken: "test-access-token", refreshToken: "test-refresh-token")
        )
    }
}
