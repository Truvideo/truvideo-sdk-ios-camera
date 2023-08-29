//
//  AuthToken.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// The authentication token containing all the values
/// from the existing session.
public struct AuthToken: Codable, Equatable {
    /// The id of the device.
    public let id: String
    
    /// The access token.
    public let accessToken: String
    
    /// The long-term token used to refresh the short term access token.
    public let refreshToken: String

    // MARK: Initializers

    /// Creates a new instance of the `AuthToken`.
    ///
    /// - Parameters:
    ///   - id: The id of the token.
    ///   - accessToken: The access token.
    ///   - refreshToken: The long-term token used to refresh the short term access token.
    public init(id: String, accessToken: String, refreshToken: String) {
        self.id = id
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
