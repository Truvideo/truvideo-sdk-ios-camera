//
//  HTTPApiClientTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import CommonCrypto
import Core
import XCTest

@testable import TruVideoCore

private extension JSONEncoder {
    /// Creates a default isntance of the `JSONEncoder` with the
    /// outputFormatting set to sortedKeys.
    ///
    /// - Note: The signature requires the keys to be sorted
    ///         alphabetically otherwise it will not work.
    static func createDefault() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        return encoder
    }
}

private extension String {
    /// Calculates the HMAC-SHA256 value for a given message using a key.
    ///
    /// - Parameters:
    ///    - msg: The message for which the HMAC will be calculated.
    ///    - key: The secret key used to calculate the HMAC.
    /// - Returns: The calculated HMAC-SHA256 value in hexadecimal format.
    func toSha256String(using key: String) -> String {
        let hmac256 = CCHmacAlgorithm(kCCHmacAlgSHA256)
        var macData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        key.withCString { keyCString in
            withCString { msgCString in
                macData.withUnsafeMutableBytes { macDataBytes in
                    guard let keyBytes = UnsafeRawPointer(keyCString)?.assumingMemoryBound(to: UInt8.self),
                          let msgBytes = UnsafeRawPointer(msgCString)?.assumingMemoryBound(to: UInt8.self) else {
                        return
                    }
                    
                    CCHmac(
                        hmac256,
                        keyBytes, Int(strlen(keyCString)),
                        msgBytes, Int(strlen(msgCString)),
                        macDataBytes.bindMemory(to: UInt8.self).baseAddress
                    )
                }
            }
        }
        
        return macData.map { String(format: "%02x", $0) }
            .joined()
    }
}

/// A struct representing the parameters that are going to be sent
/// when registering/authenticating a new device.
struct AuthenticateParameters: Encodable {
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


class HTTPApiClientTests: TruVideoCoreTests {

    // MARK: Tests

    func testHeadersAreStoreUniquelyFromArray() {
        // Given
        let sut = HTTPHeaders(
            array: [
                HTTPHeader(name: "key", value: "foo"),
                HTTPHeader(name: "Key", value: "foo"),
                HTTPHeader(name: "KEY", value: "foo")
            ]
        )

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersAreStoreUniquelyFromArrayLiteral() {
        // Given
        let sut: HTTPHeaders = [
            HTTPHeader(name: "key", value: "foo"),
            HTTPHeader(name: "Key", value: "foo"),
            HTTPHeader(name: "KEY", value: "foo")
        ]

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersAreStoreUniquelyFromDictionaryLiteral() {
        // Given
        let sut: HTTPHeaders = ["key": "foo", "Key": "foo", "KEY": "foo"]

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }
    
    func testThat() async throws {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let parameters = AuthenticateParameters(
            brand: "Apple",
            model: await UIDevice.current.name,
            os: await UIDevice.current.systemName,
            osVersion: await UIDevice.current.systemVersion,
            timestamp: timestamp
        )
        let jsonData = try JSONEncoder.createDefault().encode(parameters)

        guard let authenticationString = String(data: jsonData, encoding: .utf8) else {
            return
        }
                
        let secretKey = "ST2K33GR"
        let signature = authenticationString.toSha256String(using: secretKey)
        
        let tokenProvider = BearerTokenProvider()
        let bearerTokenRequestRetrier = BearerTokenRequestRetrier(tokenProvider: tokenProvider)
        let apiClient = HTTPApiClient(
            url: "https://sdk-mobile-api-beta.truvideo.com",
            interceptor: Interceptor(interceptors: [], retriers: [bearerTokenRequestRetrier])
        )
        let authenticationClient = HTTPAuthenticationClient(
            apiKey: "VS2SG9WK",
            apiClient: apiClient,            
            tokenProvider: TokenProviderMock()
        )
        
        try await authenticationClient.authenticate(using: signature, payload: authenticationString)
    }
}
