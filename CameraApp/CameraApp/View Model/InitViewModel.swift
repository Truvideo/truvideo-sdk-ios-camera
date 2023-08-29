//
//  InitViewModel.swift
//  CameraApp
//
//  Created by Jorge on 28/08/23.
//

import CommonCrypto
import Foundation
import TruVideoCore
import UIKit

final class InitViewModel: ObservableObject {
    let secretKey = "ST2K33GR"

    /// The current loading status.
    @Published private(set) var status: DataLoadStatus = .initial

    func `init`() {
        status = .loading

        Task { @MainActor in
            do {
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let parameters = AuthenticateParameters(
                    brand: "Apple",
                    model: UIDevice.current.name,
                    os: UIDevice.current.systemName,
                    osVersion: UIDevice.current.systemVersion,
                    timestamp: timestamp
                )

                let jsonData = try JSONEncoder.createDefault().encode(parameters)

                guard let authenticationString = String(data: jsonData, encoding: .utf8) else {
                    return
                }
                        
                let signature = authenticationString.toSha256String(using: secretKey)
                try await TruVideoSDK.`init`(apiKey: "VS2SG9WK", payload: authenticationString, signature: signature)

                status = .success
            } catch  {
                status = .failure
            }
        }
    }
}

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
