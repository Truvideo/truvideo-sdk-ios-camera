//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A struct representing different runtime environments for the TruVideo SDK.
///
/// `Environment` provides a type-safe way to handle various deployment environments
/// throughout the SDK. It uses a `String` as the raw value to identify each environment
/// and offers static properties for common environment types.
///
/// ## Overview
///
/// The SDK supports multiple environments to accommodate different stages of development
/// and deployment:
/// - **Development (DEV)**: For local development and testing
/// - **Beta (BETA)**: For beta testing and pre-release validation
/// - **Release Candidate (RC)**: For final testing before production
/// - **Production (PROD)**: For live applications
///
/// ## Usage
/// ```swift
/// // Check current environment
/// if Environment.current == .prod {
///     // Enable production-specific features
/// }
///
/// // Create custom environment
/// let customEnv = Environment(rawValue: "STAGING")
///
/// // Compare environments
/// let isProduction = Environment.current == .prod
/// ```
///
/// - Note: The `current` environment is determined at build time using the `SDK_ENVIRONMENT`
///   build setting. Make sure this is properly configured in your build configuration.
public struct Environment: Hashable, RawRepresentable, Sendable {
    // MARK: - Properties

    /// The string value that identifies this environment.
    public let rawValue: String

    // MARK: - Static Properties

    /// Beta environment for beta testing and pre-release validation.
    public static let beta = Environment(rawValue: "BETA")

    /// Development environment for local development and testing.
    public static let dev = Environment(rawValue: "DEV")

    /// Production environment for live applications.
    public static let prod = Environment(rawValue: "PROD")

    // swiftlint:disable identifier_name
    /// Release candidate environment for final testing before production.
    public static let rc = Environment(rawValue: "RC")
    // swiftlint:enable identifier_name

    // MARK: - Initializer

    /// Creates a new environment instance with the specified raw value.
    ///
    /// This initializer allows you to create custom environment instances for
    /// specialized use cases or testing purposes.
    ///
    /// ## Example
    /// ```swift
    /// // Create a custom staging environment
    /// let staging = Environment(rawValue: "STAGING")
    ///
    /// // Create a test environment
    /// let test = Environment(rawValue: "TEST")
    ///
    /// // Use in environment-specific logic
    /// if currentEnvironment == staging {
    ///     // Staging-specific behavior
    /// }
    /// ```
    ///
    /// - Parameter rawValue: The string value that identifies this environment.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
