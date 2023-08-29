//
//  TruVideo.swift
//
//  Created by TruVideo on 24/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Core
import Foundation

/// The `TruVideoSDK` class provides an interface for interacting with the TruVideo Mobile SDK.
/// It facilitates device authentication and communication with the TruVideo API for video-related operations.
public final class TruVideoSDK {
    private let authenticationClient: AuthenticationClient

    // MARK: Initializers

    /// Creates a new instance of the `TruVideoSDK`
    /// with the given authentication client.
    ///
    /// - Parameter authenticationClient: A type that handle the authentication of the users.
    init(authenticationClient: AuthenticationClient) {
        self.authenticationClient = authenticationClient
    }

    /// Authenticates the current device in order to get a new authentication token.
    ///
    /// - Parameters:
    ///    - apiKey: The key identifier of the app in the server.
    ///    - payload: The payload used when creating the signature.
    ///    - signature: The encoded signature to be sent along with the request.
    /// - Throws: A `CoreError` if the request fails
    public static func `init`(apiKey: String, payload: String, signature: String) async throws {
        do {
            let apiClient = HTTPApiClient(
                url: "https://sdk-mobile-api-beta.truvideo.com",
                monitors: [ApiClientMonitor()]
            )
            
            let authenticationClient = HTTPAuthenticationClient(
                apiKey: apiKey,
                apiClient: apiClient,
                tokenProvider: BearerTokenProvider(storage: UserDefaultsStorage())
            )
            let sdk = TruVideoSDK(authenticationClient: authenticationClient)
            try await sdk.authenticate(apiKey: apiKey, payload: payload, signature: signature)
        } catch {
            throw CoreError(kind: .initializationFailed, underlyingError: error)
        }
    }
    
    // MARK: Private methods

    /// Authenticates the current device in order to get a new authentication token.
    ///
    /// - Parameters:
    ///    - apiKey:
    ///    - payload: The payload used when creating the signature.
    ///    - signature: The encoded signature to be sent along with the request.
    /// - Throws: A `CoreError` if the request fails
    private func authenticate(apiKey: String, payload: String, signature: String) async throws {
        do {
            try await authenticationClient.authenticate(using: signature, payload: payload)
        } catch {
            throw CoreError(kind: .initializationFailed, underlyingError: error)
        }
    }
}
