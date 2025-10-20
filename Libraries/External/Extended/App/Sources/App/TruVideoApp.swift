//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
internal import InternalUtilities
internal import MediaUpload
internal import Network
internal import Networking
internal import Registry
internal import StorageKit
internal import Telemetry
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
    /// Indicates whether the user is currently authenticated with the TruVideo service.
    ///
    /// This property provides a convenient way to check authentication status without throwing errors.
    /// It returns `true` if the user has been successfully authenticated and can access SDK features;
    /// `false` if the user is not authenticated and authentication is required.
    ///
    /// ## Usage
    ///
    /// This property is commonly used to check authentication status before performing
    /// operations that require authentication:
    ///
    /// ```swift
    /// // Check authentication status
    /// if TruvideoSdk.isAuthenticated {
    ///     // User is authenticated, proceed with operations
    ///     performAuthenticatedOperation()
    /// } else {
    ///     // User needs to authenticate first
    ///     try await TruvideoSdk.authenticate()
    /// }
    /// ```
    var isAuthenticated: Bool { get }
    
    /// The configuration options used to initialize the TruVideo SDK.
    ///
    /// This property provides access to the complete configuration that was set during
    /// SDK initialization. It includes all the necessary parameters such as API credentials,
    /// signing configuration, external identifiers, and other SDK settings.
    var options: TruVideoOptions { get }
    
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
    ///
    /// - Parameters:
    ///   - apiKey: The API key credential used to identify the application or client.
    ///   - secretKey: The secret key credential used to verify the authenticity of the request.
    ///   - externalId: An optional external identifier for the user or session. Pass `nil` if not required.
    /// - Throws: An authentication error if the credentials are invalid, the service is unreachable,
    ///           or the authentication process fails for any reason.
    func authenticate(apiKey: String, secretKey: String, externalId: String?) async throws

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
    func configure(with options: TruVideoOptions)
    
    /// Signs out the current authenticated session and clears stored credentials.
    ///
    /// This method terminates the current authentication session by clearing all stored
    /// authentication data from secure storage. After calling this method, the user
    /// will be logged out and must authenticate again to access protected features.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// do {
    ///     try TruvideoSdk.signOut()
    ///     print("Successfully signed out")
    ///     // User is now logged out
    /// } catch {
    ///     print("Sign out failed: \(error)")
    ///     // Handle sign-out error
    /// }
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method is thread-safe and can be called from any thread.
    /// It performs the sign-out operation synchronously.
    ///
    /// - Throws: An error if the session cannot be cleared from storage or if the
    ///   authentication client encounters issues during the sign-out process.
    func signOut() throws

    // MARK: - Deprecated

    /// Returns the currently configured API key.
    ///
    /// - Returns: A `String` representing the configured API key.
    /// - Throws: An error if the API key is not available.
    @available(*, deprecated, message: "Use TruVideoSDK.options.apiKey instead.")
    func apiKey() throws -> String

    /// Performs client authentication using the given payload and signature.
    ///
    /// - Parameters:
    ///   - apiKey: The API key for authentication.
    ///   - payload: The signed payload (usually device context).
    ///   - signature: The HMAC signature generated from the payload.
    ///   - externalId: Optional identifier for multi-tenant support.
    /// - Throws: An error if authentication fails.
    @available(*, deprecated, message: "Use TruVideoSDK.authenticate() instead.")
    func authenticate(apiKey: String, payload: String, signature: String, externalId: String?) async throws

    /// Clears the current authentication session.
    ///
    /// - Throws: An error if sign-out fails.
    @available(*, deprecated, message: "This method is no longer needed. Use TruVideoSDK.signOut() instead.")
    func clearAuthentication() throws

    /// Generates a JSON string from the current device context.
    ///
    /// - Returns: A string representing the JSON-encoded payload.
    /// - Throws: An error if encoding fails.
    @available(
        *,
         deprecated,
         message: "This method is no longer needed. Payloads are generated internally during authentication."
    )
    func generatePayload() throws -> String

    /// Initializes the authentication process.
    ///
    /// This function was a placeholder for starting authentication. It is now deprecated.
    @available(*, deprecated, message: "No longer needed. Authentication is triggered automatically.")
    func initAuthentication() async throws

    /// Checks if the current authentication token is expired.
    ///
    /// - Returns: `true` if the token is expired; otherwise, `false`.
    @available(
        *,
         deprecated,
         message: "Token expiration is handled internally. Use TruVideoSDK.isAuthenticated() instead."
    )
    func isAuthenticationExpired() throws -> Bool
}

/// The main implementation of the TruVideo SDK.
///
/// This class provides the concrete implementation of the `TruVideoSDK` protocol,
/// handling SDK configuration, authentication, and state management. It serves
/// as the primary entry point for TruVideo SDK functionality in iOS applications.
final class TruVideoApp: TruVideoSDK {
    // MARK: - Private Properties

    private let cloudStorageProvider = S3CloudStorageProvider()
    private var hasBeenConfigured = false
    private let legacyStorage: LegacyStorage
    private let migrator: Migrator
    private let pathMonitor: any NetworkPathMonitor
    private let queue = DispatchQueue(label: "com.truvideo.app.pathMonitor.queue")

    // MARK: - Dependencies

    @Dependency(\.authenticatableClient)
    var authenticatableClient: AuthenticatableClient

    @Dependency(\.deviceSettingResource)
    private var deviceSettingResource: DeviceSettingsResource

    @Dependency(\.telemetryManager)
    private var telemetryManager: TelemetryManager

    // MARK: - Properties

    /// Indicates whether the user is currently authenticated.
    ///
    /// This property provides access to the complete configuration that was set during
    /// SDK initialization. It includes all the necessary parameters such as API credentials,
    /// signing configuration, external identifiers, and other SDK settings.
    private(set) var options = TruVideoOptions()
    
    // MARK: - Computed Properties
    
    /// Indicates whether the user is currently authenticated with the TruVideo service.
    ///
    /// This property provides a convenient way to check authentication status without throwing errors.
    /// It returns `true` if the user has been successfully authenticated and can access SDK features;
    /// `false` if the user is not authenticated and authentication is required.
    ///
    /// ## Usage
    ///
    /// This property is commonly used to check authentication status before performing
    /// operations that require authentication:
    ///
    /// ```swift
    /// // Check authentication status
    /// if TruvideoSdk.isAuthenticated {
    ///     // User is authenticated, proceed with operations
    ///     performAuthenticatedOperation()
    /// } else {
    ///     // User needs to authenticate first
    ///     try await TruvideoSdk.authenticate()
    /// }
    /// ```
    var isAuthenticated: Bool {
        authenticatableClient.currentSession != nil
    }

    // MARK: - Initializer

    /// Creates a new instance of the `TruVideoApp`.
    ///
    ///  - Parameters:
    ///     - legacyStorage: A type that defines the interface for storing authentication data in legacy storage systems.
    ///     - migrator: A type that defines the interface for performing data migrations.
    ///     - pathMonitor: A type that defines the behavior of a network path monitor.
    init(
        legacyStorage: LegacyStorage = LegacySessionStorage(),
        migrator: Migrator = SDKMigrator(),
        pathMonitor: some NetworkPathMonitor = NWPathMonitor()
    ) {

        self.legacyStorage = legacyStorage
        self.migrator = migrator
        self.pathMonitor = pathMonitor

        LibraryRegistry.register(TruVideoSDKLibrary())
        telemetryManager.add(UploadProcessor(cloudStorageProvider: cloudStorageProvider))

        pathMonitor.pathUpdateHandler = { [weak self] path in
            if let self, cloudStorageProvider.deviceSetting == nil, path.status == .satisfied {
                retrieveDeviceSettings()
            }
        }

        pathMonitor.start(queue: queue)
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
    /// - Parameters:
    ///   - apiKey: The API key credential used to identify the application or client.
    ///   - secretKey: The secret key credential used to verify the authenticity of the request.
    ///   - externalId: An optional external identifier for the user or session. Pass `nil` if not required.
    /// - Throws: An authentication error if the credentials are invalid, the service is unreachable,
    ///           or the authentication process fails for any reason.
    func authenticate(apiKey: String, secretKey: String, externalId: String?) async throws {
        guard hasBeenConfigured else {
            throw TruVideoSdkError.configurationRequired
        }

        do {
            let context = Context()
            let signature = try await options.signer.sign(context, secretKey: secretKey)

            try await authenticatableClient.authenticate(
                apiKey: apiKey,
                context: context.toContext(),
                signature: signature,
                externalId: externalId
            )
            
            if let currentSession = authenticatableClient.currentSession {
                try legacyStorage.set(currentSession.authToken, apiKey: currentSession.apiKey)
            }
            
            retrieveDeviceSettings()
        } catch let error as UtilityError {
            throw TruVideoSdkError(
                kind: .from(error.kind.rawValue),
                errorDescription: error.errorDescription,
                failureReason: error.failureReason
            )
        } catch {
            throw TruVideoSdkError.authenticationFailed
        }
    }
    
    /// Performs client authentication using the given payload and signature.
    ///
    /// - Parameters:
    ///   - apiKey: The API key for authentication.
    ///   - payload: The signed payload (usually device context).
    ///   - signature: The HMAC signature generated from the payload.
    ///   - externalId: Optional identifier for multi-tenant support.
    /// - Throws: An error if authentication fails.
    /// - Note: This method is deprecated and needs to be removed in later versions.
    func authenticate(apiKey: String, payload: String, signature: String, externalId: String?) async throws {
        guard hasBeenConfigured else {
            throw TruVideoSdkError.configurationRequired
        }

        do {
            guard let jsonData = payload.data(using: .utf8) else {
                throw TruVideoSdkError.configurationRequired
            }

            let context = try JSONDecoder().decode(TruVideoApi.Context.self, from: jsonData)
            
            try await authenticatableClient.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            if let currentSession = authenticatableClient.currentSession {
                try legacyStorage.set(currentSession.authToken, apiKey: currentSession.apiKey)
            }
            
            retrieveDeviceSettings()
        } catch let error as UtilityError {
            throw TruVideoSdkError(
                kind: .from(error.kind.rawValue),
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
    func configure(with options: TruVideoOptions) {
        if !hasBeenConfigured {
            self.options = options
            
            LibraryRegistry.configureAll()
            DependencyValues.current.environment = .rc
            DependencyValues.current.truVideoSession = HTTPURLSession(
                cache: InMemoryURLCache(),
                middleware: Middleware(interceptors: [AuthTokenInterceptor()], retriers: [SessionRequestRetrier()]),
                monitors: [SessionMonitor()]
            )
            
            try? migrator.migrate()
            retrieveDeviceSettings()
            
            hasBeenConfigured = true
        }
    }
    
    /// Signs out the current authenticated session and clears stored credentials.
    ///
    /// This method terminates the current authentication session by clearing all stored
    /// authentication data from secure storage. After calling this method, the user
    /// will be logged out and must authenticate again to access protected features.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// do {
    ///     try TruvideoSdk.signOut()
    ///     print("Successfully signed out")
    ///     // User is now logged out
    /// } catch {
    ///     print("Sign out failed: \(error)")
    ///     // Handle sign-out error
    /// }
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method is thread-safe and can be called from any thread.
    /// It performs the sign-out operation synchronously.
    ///
    /// - Throws: An error if the session cannot be cleared from storage or if the
    ///   authentication client encounters issues during the sign-out process.
    func signOut() throws {
        do {
            try authenticatableClient.signOut()
            legacyStorage.clear()
        } catch {
            throw TruVideoSdkError.signOutFailed
        }
    }

    // MARK: - Private methods

    private func retrieveDeviceSettings() {
        if isAuthenticated {
            Task {
                do {
                    let deviceSetting = try await deviceSettingResource.retrieve()
                    
                    cloudStorageProvider.deviceSetting = deviceSetting
                    try legacyStorage.set(deviceSetting)                    
                } catch {
                    // log could be added here
                }
            }
        }
    }
}
