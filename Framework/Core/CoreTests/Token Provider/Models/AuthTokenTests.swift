//
//  ResponseSerializerTests.swift
//
//  Created by TruVideo on 18/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest
@testable import Core

final class AuthTokenTests: CoreTests {

    // MARK: Tests

    func testThatInit() throws {
        // Given
        let sut = AuthToken(id: "foo", accessToken: "AccessToken", refreshToken: "RefereshToken")

        // When, Then
        XCTAssertNotNil(sut)
    }
}
