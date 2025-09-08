//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
@_spi(Internal) import ExternalUtilities
import Foundation
internal import Registry
internal import Storage
internal import TruVideoApi
internal import Utilities

/// The main protocol for TruVideo SDK functionality.
///
/// This protocol defines the core interface for TruVideo SDK operations including
/// configuration, authentication, and status checking. Implementations of this
/// protocol provide the main entry point for SDK functionality.
///
/// ## Usage
///
/// ```swift
/// // Configure the SDK
/// try TruvideoSdk.configure(with: options)
///
/// // Check authentication status
/// if TruvideoSdk.isAuthenticated {
///     // User is authenticated
/// }
///
/// // Authenticate the user
/// try await TruvideoSdk.authenticate()
/// ```
///
/// ## Lifecycle
///
/// 1. **Configuration**: Call `configure(with:)` to set up the SDK
/// 2. **Authentication**: Call `authenticate()` to authenticate the user
/// 3. **Status Check**: Use `isAuthenticated` to check authentication status
///
/// ## Error Handling
///
/// ```swift
/// do {
///     try TruvideoSdk.configure(with: options)
///     try await TruvideoSdk.authenticate()
/// } catch TruVideoSdkError.configurationRequired {
///     // Handle configuration error
/// } catch TruVideoSdkError.authenticationFailed {
///     // Handle authentication error
/// } catch {
///     // Handle other errors
/// }
/// ```
///
/// ## Thread Safety
///
/// All methods in this protocol are thread-safe and can be called from any thread.
/// The SDK handles concurrent access internally.
///
/// ## Implementation Notes
///
/// - **Configuration**: Must be called before any other operations
/// - **Authentication**: Required after configuration to enable SDK features
/// - **Status Check**: Safe to call at any time
///
/// - Note: This protocol is the primary interface for TruVideo SDK operations.
/// - Important: Always configure the SDK before attempting authentication.
/// - Warning: Authentication is required to use most SDK features.
public protocol TruVideoSDK {
    /// Indicates whether the user is currently authenticated.
    ///
    /// This property returns `true` if the user has successfully authenticated
    /// and the authentication token is valid. Returns `false` if the user
    /// has not authenticated or the authentication has expired.
    var isAuthenticated: Bool { get }

    /// Authenticates the user with the TruVideo service.
    ///
    /// This method performs device authentication by sending device context information
    /// along with a cryptographic signature to verify the client's identity. Upon successful
    /// authentication, an access token is received and stored for future API requests.
    ///
    /// ## Prerequisites
    ///
    /// - The SDK must be configured using `configure(with:)` before calling this method
    /// - Valid API credentials must be provided during configuration
    ///
    /// ## Error Handling
    ///
    /// ```swift
    /// do {
    ///     try await TruvideoSdk.authenticate()
    /// } catch TruVideoSdkError.configurationRequired {
    ///     // SDK not configured
    ///     TruvideoSdk.configure(with: options)
    ///     try await TruvideoSdk.authenticate()
    /// } catch TruVideoSdkError.authenticationFailed {
    ///     // Authentication failed
    ///     showAuthenticationError("Please check your credentials")
    /// } catch {
    ///     // Other errors
    ///     showGenericError("Authentication failed")
    /// }
    /// ```
    func authenticate() async throws

    /// Configures the TruVideo SDK with the specified options.
    ///
    /// This method sets up the SDK with the provided configuration options including
    /// API credentials, signing configuration, and other settings. Configuration
    /// must be performed before any other SDK operations.
    ///
    /// ## Error Handling
    ///
    /// ```swift
    /// do {
    ///     try TruvideoSdk.configure(with: options)
    /// } catch TruVideoSdkError.alreadyConfigured {
    ///     // SDK already configured, continue normally
    ///     print("SDK already configured")
    /// } catch {
    ///     // Handle other configuration errors
    ///     print("Configuration failed: \(error)")
    /// }
    /// ```
    /// - Parameter options: The configuration options containing API credentials, signing configuration, and other SDK settings
    /// - Throws: `TruVideoSdkError.alreadyConfigured` if the SDK has already been configured.
    func configure(with options: TruVideoOptions) throws
}

/// The main implementation of the TruVideo SDK.
///
/// This class provides the concrete implementation of the `TruVideoSDK` protocol,
/// handling SDK configuration, authentication, and state management. It serves
/// as the primary entry point for TruVideo SDK functionality in iOS applications.
public final class TruVideoApp: TruVideoSDK {
    // MARK: - Private Properties

    private var hasBeenConfigured = false
    private let legacyStorage: LegacyStorage
    private let migrator: Migrator

    // MARK: - Dependencies

    @Dependency(\.authenticatableClient)
    private var authenticatableClient: AuthenticatableClient

    @Dependency(\.deviceSettingResource)
    private var deviceSettingResource: DeviceSettingsResource

    @Dependency(\.options)
    private var options: TruVideoOptions

    // MARK: - Computed Properties

    /// Indicates whether the user is currently authenticated.
    ///
    /// This property returns `true` if the user has successfully authenticated
    /// and the authentication token is valid. Returns `false` if the user
    /// has not authenticated or the authentication has expired.
    public var isAuthenticated: Bool {
        authenticatableClient.currentToken != nil
    }

    // MARK: - Initializer

    /// Creates a new instance of the `TruVideoApp`.
    ///
    ///  - Parameters:
    ///     - legacyStorage: A type that defines the interface for storing authentication data in legacy storage systems.
    ///     - migrator: A type that defines the interface for performing data migrations.
    init(legacyStorage: LegacyStorage = LegacySessionStorage(), migrator: Migrator = SDKMigrator()) {
        self.legacyStorage = legacyStorage
        self.migrator = migrator

        LibraryRegistry.register(TruVideoSDKLibrary())
    }

    // MARK: - TruVideoSDK

    /// Authenticates the user with the TruVideo service.
    ///
    /// This method performs device authentication by sending device context information
    /// along with a cryptographic signature to verify the client's identity. Upon successful
    /// authentication, an access token is received and stored for future API requests.
    ///
    /// ## Prerequisites
    ///
    /// - The SDK must be configured using `configure(with:)` before calling this method
    /// - Valid API credentials must be provided during configuration
    ///
    /// ## Error Handling
    ///
    /// ```swift
    /// do {
    ///     try await TruvideoSdk.authenticate()
    /// } catch TruVideoSdkError.configurationRequired {
    ///     // SDK not configured
    ///     TruvideoSdk.configure(with: options)
    ///     try await TruvideoSdk.authenticate()
    /// } catch TruVideoSdkError.authenticationFailed {
    ///     // Authentication failed
    ///     showAuthenticationError("Please check your credentials")
    /// } catch {
    ///     // Other errors
    ///     showGenericError("Authentication failed")
    /// }
    /// ```
    public func authenticate() async throws {
        guard hasBeenConfigured else {
            throw TruVideoSdkError.configurationRequired
        }

        do {
            let context = Context()
            let signature = try await options.signer.sign(context, secretKey: options.secretKey)

            try await authenticatableClient.authenticate(
                apiKey: options.apiKey,
                context: context.toContext(),
                signature: signature,
                externalId: options.externalId
            )
            
            if let authToken = authenticatableClient.currentToken {
                try legacyStorage.set(authToken, apiKey: options.apiKey)
            }
            
            retrieveDeviceSettings()
        } catch let error as UtilityError {
            throw TruVideoSdkError(
                kind: .TruVideoSdkErrorReason.from(error.kind.rawValue),
                errorDescription: error.errorDescription,
                failureReason: error.failureReason
            )
        } catch {
            throw TruVideoSdkError.authenticationFailed
        }
    }

    /// Configures the TruVideo SDK with the specified options.
    ///
    /// This method sets up the SDK with the provided configuration options including
    /// API credentials, signing configuration, and other settings. Configuration
    /// must be performed before any other SDK operations.
    ///
    /// ## Error Handling
    ///
    /// ```swift
    /// do {
    ///     try TruvideoSdk.configure(with: options)
    /// } catch TruVideoSdkError.alreadyConfigured {
    ///     // SDK already configured, continue normally
    ///     print("SDK already configured")
    /// } catch {
    ///     // Handle other configuration errors
    ///     print("Configuration failed: \(error)")
    /// }
    /// ```
    /// - Parameter options: The configuration options containing API credentials, signing configuration, and other SDK settings
    /// - Throws: `TruVideoSdkError.alreadyConfigured` if the SDK has already been configured.
    public func configure(with options: TruVideoOptions) throws {
        guard !hasBeenConfigured else {
            throw TruVideoSdkError.appAlreadyConfigured
        }

        do {
            try migrator.migrate()
        } catch {
            throw TruVideoSdkError.unknown
        }
        
        DependencyValues.current.options = options
        LibraryRegistry.configureAll()
        retrieveDeviceSettings()
        hasBeenConfigured = true
    }

    // MARK: - Private methods

    private func retrieveDeviceSettings() {
        guard isAuthenticated else { return }

        Task {
            do {
                let deviceSetting = try await deviceSettingResource.retrieve()
                /// Create s3 uploader for telemetry
            } catch {
                // log could be added here
            }
        }
    }
}
