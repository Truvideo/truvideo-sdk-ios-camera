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
            authToken: AuthToken(id: UUID(uuidString: "36BBA8E7-A9C6-4F00-B4E1-F6BA888FF093")!, accessToken: "test-access-token", refreshToken: "test-refresh-token")
        )
    }
}
