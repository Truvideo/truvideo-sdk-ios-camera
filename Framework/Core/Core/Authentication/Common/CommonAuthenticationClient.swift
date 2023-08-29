////
////  CommonAuthenticationClient.swift
////
////  Created by TruVideo on 8/08/23.
////  Copyright © TruVideo. All rights reserved.
////
//
//import Foundation
//import shared
//
///// A type that defines the standard interaction behavior with the third
///// party multiplatform framework and enable secure access.
//public final class CommonAuthenticationClient: AuthenticationClient {
//    private let apiKey: String
//
//    // MARK: Initializers
//
//    /// Creates a new instance of the `CommonAuthenticationClient` with the
//    /// given api key.
//    ///
//    /// - Parameters apiKey: The key identifier of the app in the server.
//    public init(apiKey: String) {
//        self.apiKey = apiKey
//    }
//
//    // MARK: AuthenticationClient
//
//    /// Authenticates the current device in order to get a new authentication token.
//    ///
//    /// - Parameters:
//    ///    - signature: The encoded signature to be sent along with the request.
//    ///    - payload: The payload used when creating the signature.
//    /// - Throws: A `CoreError` if the request fails
//    public func authenticate(using signature: String, payload: String) async throws {
//        do {
//            let truVideoSDK = TruvideoSdk()
//            try await truVideoSDK.auth.authenticate(apiKey: apiKey, payload: payload, signature: signature)
//        } catch {
//            throw CoreError(kind: .authenticateFailed, underlyingError: error)
//        }
//    }
//}
