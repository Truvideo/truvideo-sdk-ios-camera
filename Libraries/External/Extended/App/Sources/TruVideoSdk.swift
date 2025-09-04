//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
/// The main entry point for the TruVideo SDK.
///
/// This is a singleton instance that provides access to all TruVideo SDK functionality.
/// It serves as the primary interface for configuring, authenticating, and using the SDK
/// in your iOS application.
///
/// ## Usage
///
/// ```swift
/// import TruVideoSdk
///
/// // Configure the SDK
/// TruvideoSdk.configure(with: options)
///
/// // Check if configured
/// if TruvideoSdk.isConfigured {
///     // SDK is ready to use
/// }
///
/// // Authenticate
/// try await TruvideoSdk.authenticate()
///
/// // Check authentication status
/// if TruvideoSdk.isAuthenticated {
///     // User is authenticated
/// }
/// ```
///
/// ## Configuration
///
/// Before using any SDK features, you must configure the SDK with your credentials:
///
/// ```swift
/// let options = TruVideoOptions(
///     apiKey: "your-api-key",
///     secretKey: "your-secret-key",
///     externalId: "user-id" // optional
/// )
///
/// TruvideoSdk.configure(with: options)
/// ```
///
/// ## Authentication
///
/// After configuration, authenticate the user to enable SDK features:
///
/// ```swift
/// do {
///     try await TruvideoSdk.authenticate()
///     print("Authentication successful")
/// } catch {
///     print("Authentication failed: \(error)")
/// }
/// ```
///
/// ## Thread Safety
///
/// This instance is thread-safe and can be accessed from any thread. All operations
/// are designed to be safe for concurrent access.
///
/// ## Lifecycle
///
/// - **Initialization**: The instance is created when the module is loaded
/// - **Configuration**: Must be called before using any SDK features
/// - **Authentication**: Required after configuration to enable functionality
/// - **Usage**: Safe to use throughout the application lifecycle
///
/// ## Error Handling
///
/// The SDK provides comprehensive error handling for configuration and authentication:
///
/// ```swift
/// do {
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
/// - Note: This instance is the primary way to interact with the TruVideo SDK.
/// - Important: Always configure the SDK before attempting to use any features.
/// - Warning: Authentication is required after configuration to enable SDK functionality.
public let TruvideoSdk: any TruVideoSDK = TruVideoApp()
// swiftlint:enable identifier_name
