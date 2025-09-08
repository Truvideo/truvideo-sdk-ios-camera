//
//  MockAuthValidator.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import Foundation

class MockAuthValidator: AuthValidator {
    private let userIsAuthenticated: Bool

    init(userIsAuthenticated: Bool = true) {
        self.userIsAuthenticated = userIsAuthenticated
    }

    func isAuthenticated() -> Bool {
        userIsAuthenticated
    }
}
