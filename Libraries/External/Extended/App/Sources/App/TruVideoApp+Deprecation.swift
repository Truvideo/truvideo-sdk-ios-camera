//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
internal import TruVideoApi
internal import Utilities

extension TruVideoSdkError {
    /// Error indicating that the required API key could not be found or retrieved.
    ///
    /// This error occurs when the SDK attempts to access an API key that is either
    /// missing, invalid, or cannot be retrieved from the configured source
    public static let apiKeyNotFound = TruVideoSdkError(
        kind: TruVideoSdkError.ErrorReason(rawValue: "apiKeyNotFound"),
        errorDescription: "API key not found or unavailable.",
        failureReason: "The required API key could not be retrieved from the configured source."
    )

    /// Failed to generate the request payload.
    ///
    /// This error occurs when the SDK fails to encode or assemble the expected payload
    /// for a request due to invalid or missing data.
    public static let payloadGenerationFailed = TruVideoSdkError(
        kind: TruVideoSdkError.ErrorReason(rawValue: "payloadGenerationFailed"),
        errorDescription: "Unable to generate request payload.",
        failureReason: "The data provided could not be encoded or was invalid."
    )
}

extension TruVideoApp {
    // MARK: - TruVideoSDKDeprecated

    /// Returns the currently configured API key.
    ///
    /// - Returns: A `String` representing the configured API key.
    /// - Throws: An error if the API key is not available.
    public func apiKey() throws -> String {
        guard let apiKey = authenticatableClient.currentSession?.apiKey else {
            throw TruVideoSdkError.apiKeyNotFound
        }

        return apiKey
    }

    /// Clears the current authentication session.
    ///
    /// - Throws: An error if sign-out fails.
    public func clearAuthentication() throws {
        try signOut()
    }

    /// Generates a JSON string from the current device context.
    ///
    /// - Returns: A string representing the JSON-encoded payload.
    /// - Throws: An error if encoding fails.
    public func generatePayload() throws -> String {
        do {
            let context = Context()
            let jSONEncoder = JSONEncoder()
            jSONEncoder.outputFormatting = [.sortedKeys]

            let jsonData = try jSONEncoder.encode(context)

            guard let payload = String(data: jsonData, encoding: .utf8) else {
                throw TruVideoSdkError.payloadGenerationFailed
            }

            return payload
        } catch {
            throw TruVideoSdkError.payloadGenerationFailed
        }
    }

    /// Initializes the authentication process.
    ///
    /// This function was a placeholder for starting authentication. It is now deprecated.
    public func initAuthentication() async throws {}

    /// Checks if the current authentication token is expired.
    ///
    /// - Returns: `true` if the token is expired; otherwise, `false`.
    public func isAuthenticationExpired() throws -> Bool {
        authenticatableClient.currentSession == nil
    }
}
