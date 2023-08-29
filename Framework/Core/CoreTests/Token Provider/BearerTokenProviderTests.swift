//
//  BearerTokenProviderTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

final class BearerTokenProviderTests: CoreTests {

    // MARK: Tests

    func testThatRetrieveToken() async throws {
        // Given
        let storage = StorageMock()
        let sut = BearerTokenProvider(storage: storage)
        let token = AuthToken(id: "Id", accessToken: "Access", refreshToken: "Refresh")

        // When
        try storage.write(token, forKey: "org.tru-video.auth-token")
        let savedToken = await sut.retrieveToken()

        // Then
        XCTAssertEqual(token, savedToken)
    }

    func testThatRetrieveTokenNoFoundInformation() async throws {
        // Given
        let storage = StorageMock()
        let sut = BearerTokenProvider(storage: storage)

        // When
        let savedToken = await sut.retrieveToken()

        // Then
        XCTAssertNil(savedToken)
    }

    func testThatRetrieveTokenOnStorageFailure() async throws {
        // Given
        let storage = StorageMock()
        let sut = BearerTokenProvider(storage: storage)

        // When
        storage.error = NSError(domain: "", code: 0)
        let savedToken = await sut.retrieveToken()

        // Then
        XCTAssertNil(savedToken)
    }

    func testThatSaveToken() async throws {
        // Given
        let storage = StorageMock()
        let sut = BearerTokenProvider(storage: storage)
        let token = AuthToken(id: "Id", accessToken: "Access", refreshToken: "Refresh")

        // When
        try await sut.save(token)

        // Then
        let savedToken = try storage.readValue(AuthToken.self, forKey: "org.tru-video.auth-token")
        XCTAssertEqual(savedToken, token)
    }
}
