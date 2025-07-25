//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import Storage
import Utilities

public protocol AuthenticatableClient {
    func authenticate(apiKey: String, context: Context, signature: String, externalId: String?) async throws
}

extension AuthenticatableClient {
    public func authenticate(
        apiKey: String,
        context: Context,
        signature: String,
        externalId: String? = nil
    ) async throws {

        try await authenticate(apiKey: apiKey, context: context, signature: signature, externalId: externalId)
    }
}

public final class AuthenticationClient: AuthenticatableClient {
    // MARK: - Private Properties

    private let session: Session

    // MARK: - Dependencies

    @Dependency(\.apiEnvironment)
    private var environment: Environment

    @Dependency(\.storage)
    private var storage: Storage

    // MARK: - Initializer

    init(session: any Session) {
        self.session = session
    }

    public convenience init() {
        self.init(session: HTTPURLSession())
    }

    // MARK: - AuthenticatableClient

    public func authenticate(apiKey: String, context: Context, signature: String, externalId: String?) async throws {
        do {
            var headers: HTTPHeaders = [
                "x-authentication-api-key": apiKey,
                "x-authentication-signature": signature,
            ]

            if let externalId, !externalId.isEmpty {
                headers["x-multitenant-external-id"] = externalId
            }

            let response = try await session.request(
                environment.baseURL.appending("/api/device"),
                method: .post,
                parameters: [
                    "": ""
                ],
                headers: headers
            )
            .serializing(String.self)
            .result
            .get()
        } catch {

        }
    }
}
