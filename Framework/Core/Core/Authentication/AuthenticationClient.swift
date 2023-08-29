//
//  AuthenticationClient.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A type that handle the authentication of the users.
public protocol AuthenticationClient {
    /// Authenticates the current device in order to get a new authentication token.
    ///
    /// - Parameters:
    ///    - signature: The encoded signature to be sent along with the request.
    ///    - payload: The payload used when creating the signature.
    /// - Throws: A `CoreError` if the request fails
    func authenticate(using signature: String, payload: String) async throws
}
