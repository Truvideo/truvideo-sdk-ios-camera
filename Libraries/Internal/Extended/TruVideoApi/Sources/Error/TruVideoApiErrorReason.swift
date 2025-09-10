//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the signer.
    ///
    /// The `TruVideoApiErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct TruVideoApiErrorReason: Sendable {
        /// Error indicating that the authentication process has failed.
        ///
        /// This error occurs when the authentication request to the TruVideo API fails
        /// due to invalid credentials, server errors, or network connectivity issues.
        /// Authentication is required before accessing protected API resources.
        public static let authenticationFailed = ErrorReason(rawValue: "authenticationFailed")

        /// Error indicating that the device settings retrieval process has failed.
        ///
        /// This error occurs when attempting to fetch device settings from the TruVideo API
        /// but the request fails due to network issues, server errors, or invalid responses.
        /// The device settings contain configuration parameters and feature flags needed
        /// for proper SDK operation.
        public static let deviceSettingsRetrivalFailed = ErrorReason(rawValue: "deviceSettingsRetrivalFailed")

        /// Error indicating that the authentication process has failed due to an invalid API key.
        ///
        /// This error occurs when the provided API key is invalid, expired, or malformed.
        /// The API key is used to identify the application and must be valid for
        /// successful authentication with the TruVideo API.
        public static let invalidApiKey = ErrorReason(rawValue: "error.invalidApiKey")

        /// Error indicating that the authentication process has failed due to an invalid signature.
        ///
        /// This error occurs when the cryptographic signature of the device context data
        /// is invalid, malformed, or cannot be verified by the server. The signature
        /// is created using the secret key and is required for secure authentication.
        public static let invalidSignature = ErrorReason(rawValue: "Invalid signature")

        /// Error indicating that the refresh token process has failed.
        ///
        /// This error occurs when attempting to refresh an expired access token using
        /// the refresh token. The refresh process may fail due to invalid refresh tokens,
        /// server errors, or network connectivity issues.
        public static let refreshTokenFailed = ErrorReason(rawValue: "refreshTokenFailed")

        /// Error indicating that signing the context has failed.
        ///
        /// This error occurs when the cryptographic signing of device context data fails
        /// during the authentication process. This may be due to invalid secret keys,
        /// malformed context data, or cryptographic algorithm issues.
        public static let signFailed = ErrorReason(rawValue: "signFailed")

        /// Error indicating that the sign-out process has failed.
        ///
        /// This error occurs when the attempt to delete the current authentication session
        /// from secure storage fails. It may be due to underlying storage issues such as
        /// access denial, corruption, or internal exceptions during the deletion process.
        /// A failed sign-out may result in the session remaining active.
        public static let signOutFailed = ErrorReason(rawValue: "signOutFailed")

        /// Error indicating that the user is not authenticated.
        ///
        /// This error occurs when attempting to access protected resources or perform
        /// operations that require authentication, but no valid authentication session
        /// is available. The user needs to authenticate before proceeding.
        public static let unauthenticated = ErrorReason(rawValue: "unauthenticated")
    }
}
