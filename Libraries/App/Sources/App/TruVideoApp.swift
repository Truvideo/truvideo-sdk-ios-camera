//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Registry
import TruVideoApi

public protocol TruVideoSDK {
    var isAuthenticated: Bool { get }

    func authenticate() async throws

    func configure(with options: TruVideoOptions)
}

public final class TruVideoApp: TruVideoSDK {
    // MARK: - Private Properties

    private var hasBeenConfigured = false

    // MARK: - Dependencies

    @Dependency(\.authenticatableClient)
    private var authenticatableClient: AuthenticatableClient

    @Dependency(\.options)
    private var options: TruVideoOptions

    // MARK: - Computed Properties

    public var isAuthenticated: Bool {
        true
    }

    // MARK: - Initializer

    init() {
        LibraryRegistry.register(TruVideoSDKLibrary())
    }

    // MARK: - TruVideoSDK

    public func authenticate() async throws {
        do {
            let context = Context()
            let signature = try await options.signer.sign(context, secretKey: options.secretKey)

            try await authenticatableClient.authenticate(
                apiKey: options.apiKey,
                context: context,
                signature: signature,
                externalId: options.externalId
            )
        } catch {

        }
    }

    public func configure(with options: TruVideoOptions) {
        if !hasBeenConfigured {
            DependencyValues.current.options = options
            LibraryRegistry.configureAll()
            hasBeenConfigured = true
        }
    }
}
