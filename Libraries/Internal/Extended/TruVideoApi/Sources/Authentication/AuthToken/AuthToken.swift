//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A token object containing authentication credentials for API access.
///
/// `AuthToken` represents the authentication credentials received from the TruVideo API
/// after successful authentication. It contains both an access token for immediate API
/// access and a refresh token for obtaining new access tokens when they expire.
///
/// - Note: Tokens should be treated as sensitive data and handled securely.
/// - Warning: Never expose tokens in logs, URLs, or client-side code.
public struct AuthToken: Codable, Sendable {
    /// A unique identifier for this authentication session.
    ///
    /// Used to track and manage multiple authentication sessions,
    /// especially useful when supporting multiple user accounts or
    /// handling token refresh scenarios.
    public let id: UUID

    /// A JWT (JSON Web Token) used for API authentication.
    public let accessToken: String

    /// A long-lived token used to obtain new access tokens.
    ///
    /// When the `accessToken` expires, use this token to request a new
    /// access token without requiring user re-authentication.
    public let refreshToken: String
}
