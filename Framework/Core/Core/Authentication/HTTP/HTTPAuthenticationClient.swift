//
//  HTTPAuthenticationClient.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

extension JSONDecoder: Decoder {}

/// A struct representing the parameters that are going to be sent
/// when registering/authenticating a new device.
private struct AuthenticateParameters: Codable {
    /// The brand of the device.
    let brand: String
    
    /// The device model.
    let model: String
    
    /// The os being used.
    let os: String
    
    /// The os version.
    let osVersion: String
    
    /// The time interval date when the device
    /// was registered.
    let timestamp: Int
}

/// A protocol that defines the behavior allowed when decoding values.
public protocol Decoder {
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - Parameters:
    ///    - type: The type of the value to decode.
    ///    - data: The data to decode from.
    /// - Returns: A value of the requested type.
    /// - Throws: An error if any value throws an error during decoding.
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

/// A type that defines the standard interaction behavior with the
/// server and enables secure access to the user.
public final class HTTPAuthenticationClient: AuthenticationClient {
    private let apiClient: HTTPApiClient
    private let apiKey: String
    private let decoder: Decoder
    private let tokenProvider: TokenProvider

    // MARK: Initializers

    /// Creates a new instance of the `HTTPAuthenticationClient` with the
    /// given `ApiClient`.
    ///
    /// - Parameters:
    ///   - apiKey: The key identifier of the app in the server.
    ///   - apiClient: The `ApiClient` to use for the sever communication.
    ///   - decoder: The decoder to use when decoding the parameters.
    ///   - tokenProvider: Provides an abstraction for access token retrieval.
    public init(
        apiKey: String,
        apiClient: HTTPApiClient,
        tokenProvider: TokenProvider,
        decoder: Decoder = JSONDecoder()
    ) {

        self.apiClient = apiClient
        self.apiKey = apiKey
        self.decoder = decoder
        self.tokenProvider = tokenProvider
    }
    
    // MARK: AuthenticationClient
    
    /// Authenticates the current device in order to get a new authentication token.
    ///
    /// - Parameters:
    ///    - signature: The encoded signature to be sent along with the request.
    ///    - payload: The payload used when creating the signature.
    /// - Throws: A `CoreError` if the request fails
    public func authenticate(using signature: String, payload: String) async throws {
        do {
            var headers = ["x-authentication-api-key": apiKey, "x-authentication-signature": signature]
            
            if let authToken = await tokenProvider.retrieveToken() {
                headers["x-authentication-device-id"] = authToken.id
            }
            
            let parameters = try decoder.decode(AuthenticateParameters.self, from: Data(payload.utf8))
            let response = try await apiClient.request(
                "api/device",
                method: .post,
                parameters: parameters,
                headers: HTTPHeaders(dictionary: headers)
            )
            .validate()
            .serializing(AuthToken.self)
            .response
            
            let token = try response.result.get()
            try await tokenProvider.save(token)
        } catch {
            throw CoreError(kind: .authenticateFailed, underlyingError: error)
        }
    }
}
