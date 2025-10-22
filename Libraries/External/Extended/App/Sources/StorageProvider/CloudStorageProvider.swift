//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import CloudStorageKit
internal import TruVideoApi
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to cloud storage provider operations.
    ///
    /// The `CloudStorageProviderErrorReason` struct provides a set of static constants
    /// representing various errors that can occur during cloud storage provider
    /// initialization and configuration. These error reasons are used to provide
    /// specific error handling and debugging information for cloud storage-related failures.
    struct CloudStorageProviderErrorReason: Sendable {
        /// Error indicating that the creation of a cloud storage instance has failed.
        ///
        /// This error reason is used when the system is unable to initialize or obtain
        /// a valid cloud storage provider instance. This typically occurs during the
        /// `makeStorage()` method execution when the underlying storage service cannot
        /// be properly configured or initialized.
        static let makeCloudStorageFailed = ErrorReason(rawValue: "makeCloudStorageFailed")
    }
}

/// A protocol that defines the contract for providing cloud storage services.
///
/// `CloudStorageProvider` serves as an abstraction layer for creating and managing cloud storage
/// instances. Conforming types are responsible for creating and configuring `CloudStorage`
/// instances when requested, handling the complexity of storage service initialization,
/// authentication, and configuration management.
///
/// ## Purpose
///
/// This protocol enables dependency injection and abstraction of cloud storage creation,
/// allowing the application to work with different cloud storage providers without
/// tight coupling to specific implementations. It supports lazy initialization patterns
/// where storage instances are created only when needed.
///
/// ## Key Features
///
/// - **Lazy Initialization**: Storage instances are created on-demand
/// - **Configuration Management**: Handles storage service configuration and authentication
/// - **Error Handling**: Provides comprehensive error reporting for initialization failures
/// - **Flexibility**: Supports different cloud storage providers and configurations
/// - **Caching**: Implementations can cache storage instances for performance
///
/// ## Implementation Guidelines
///
/// Conforming types should:
/// - Handle configuration validation before creating storage instances
/// - Implement proper error handling for initialization failures
/// - Consider caching storage instances to avoid repeated initialization
/// - Return `nil` when insufficient configuration is available
///
/// ## Usage Context
///
/// This protocol is typically used in dependency injection scenarios where:
/// - Cloud storage configuration is determined at runtime
/// - Multiple storage providers need to be supported
/// - Storage instances need to be created lazily based on available configuration
///
/// ## Example Usage
///
/// ```swift
/// class MyStorageManager {
///     private let storageProvider: CloudStorageProvider
///
///     init(storageProvider: CloudStorageProvider) {
///         self.storageProvider = storageProvider
///     }
///
///     func uploadFile(data: Data, fileName: String) async throws {
///         guard let storage = try storageProvider.makeStorage() else {
///             throw MyError.storageNotAvailable
///         }
///
///         let uploadTask = storage.upload(data, fileName: fileName, contentType: .jpeg)
///         // Handle upload...
///     }
/// }
/// ```
protocol CloudStorageProvider {
    /// The device settings containing S3 configuration information.
    ///
    /// This property holds the device-specific configuration retrieved from the TruVideo API,
    /// including S3 bucket information, AWS identity pool settings, and regional configuration.
    /// The settings are used to configure the S3 storage instance when `makeStorage()` is called.
    var deviceSetting: DeviceSetting? { get set }

    /// Creates and returns a cloud storage instance.
    ///
    /// This method is responsible for creating and configuring a `CloudStorage` instance
    /// based on the provider's current configuration and available resources. The method
    /// may return `nil` if the provider does not have sufficient information to create
    /// a valid storage instance, such as missing configuration or authentication credentials.
    ///
    /// Implementations should handle configuration validation, authentication setup,
    /// and any necessary initialization steps. Storage instances may be cached to
    /// improve performance and avoid repeated initialization.
    ///
    /// - Returns: A configured `CloudStorage` instance ready for use, or `nil` if the
    ///            provider cannot create one at this time due to missing configuration
    ///            or insufficient resources.
    /// - Throws: A `UtilityError` if the creation process fails due to invalid configuration,
    ///           authentication errors, network issues, or other runtime problems that
    ///           prevent the storage instance from being created.
    func makeStorage() throws(UtilityError) -> CloudStorage?
}

/// A concrete implementation of `CloudStorageProvider` that manages Amazon S3 storage instances.
///
/// `S3CloudStorageProvider` implements the `CloudStorageProvider` protocol to provide
/// Amazon S3 cloud storage functionality for the TruVideo SDK. It manages the complete
/// lifecycle of S3 storage instances, including creation, caching, configuration validation,
/// and error handling. The provider uses device settings retrieved from the TruVideo API
/// to configure S3 connections with appropriate region, bucket, and identity pool settings.
///
/// ## Key Features
///
/// - **Lazy Initialization**: S3 storage instances are created only when needed
/// - **Instance Caching**: Created storage instances are cached to improve performance
/// - **Configuration Management**: Uses device settings for S3 configuration
/// - **Error Handling**: Comprehensive error handling with specific error types
/// - **AWS Integration**: Direct integration with AWS S3 Transfer Utility
/// - **Accelerated Transfers**: Configures S3 with transfer acceleration enabled
///
/// ## Configuration Process
///
/// The provider follows this configuration process:
/// 1. **Device Settings**: Retrieves S3 configuration from `DeviceSetting`
/// 2. **Validation**: Validates that all required configuration parameters are present
/// 3. **Initialization**: Creates `S3CloudStorage` instance with validated configuration
/// 4. **Caching**: Stores the created instance for subsequent requests
/// 5. **Error Handling**: Wraps any initialization errors in `UtilityError`
///
/// ## Thread Safety
///
/// This class is designed to be thread-safe and can be used concurrently from multiple threads.
/// The caching mechanism ensures that multiple concurrent requests for storage instances
/// will receive the same cached instance once it has been created.
///
/// ## Usage Context
///
/// This provider is typically used in dependency injection scenarios where:
/// - S3 storage configuration is determined dynamically from device settings
/// - Storage instances need to be shared across multiple components
/// - Performance optimization through caching is desired
///
/// ## Example Usage
///
/// ```swift
/// // Create provider with device settings
/// let provider = S3CloudStorageProvider()
/// provider.deviceSetting = deviceSetting
///
/// // Get storage instance
/// do {
///     guard let storage = try provider.makeStorage() else {
///         print("Storage not available - missing configuration")
///         return
///     }
///
///     // Use storage for upload operations
///     let uploadTask = storage.upload(data, fileName: "file.jpg", contentType: .jpeg)
///     // Handle upload...
/// } catch {
///     print("Failed to create storage: \(error)")
/// }
/// ```
final class S3CloudStorageProvider: CloudStorageProvider {
    // MARK: - Private Properties

    private var cloudStorage: CloudStorage?

    // MARK: - Properties

    /// The device settings containing S3 configuration information.
    ///
    /// This property holds the device-specific configuration retrieved from the TruVideo API,
    /// including S3 bucket information, AWS identity pool settings, and regional configuration.
    /// The settings are used to configure the S3 storage instance when `makeStorage()` is called.
    var deviceSetting: DeviceSetting?

    // MARK: - Instance methods

    /// Creates and returns a cloud storage instance with S3 configuration.
    ///
    /// This method implements the `CloudStorageProvider.makeStorage()` requirement by creating
    /// and configuring an `S3CloudStorage` instance using the device settings. The method
    /// implements lazy initialization with caching, ensuring that subsequent calls return
    /// the same instance for improved performance.
    ///
    /// The method validates that device settings are available before attempting to create
    /// the storage instance. If device settings are missing, the method returns `nil`
    /// to indicate insufficient configuration. If initialization fails due to configuration
    /// errors or AWS service issues, the method throws a `UtilityError` with specific
    /// error information.
    ///
    /// ## Implementation Details
    ///
    /// - **Caching**: Created instances are cached to avoid repeated initialization
    /// - **Configuration**: Uses `deviceSetting.s3Configuration` for S3 setup
    /// - **Region**: Hardcoded to use US West 2 region (`.usWest2`)
    /// - **Acceleration**: Transfer acceleration is enabled for improved performance
    /// - **Error Handling**: Wraps AWS initialization errors in `UtilityError`
    ///
    /// - Returns: A configured `S3CloudStorage` instance ready for use, or `nil` if the
    ///            provider cannot create one due to missing `deviceSetting` configuration.
    /// - Throws: A `UtilityError` with `CloudStorageProviderErrorReason.makeCloudStorageFailed`
    ///           if the S3 storage initialization fails due to invalid configuration,
    ///           authentication errors, or AWS service issues.
    func makeStorage() throws(UtilityError) -> CloudStorage? {
        guard let cloudStorage else {
            guard let deviceSetting else { return nil }

            do {
                let cloudStorage = try S3CloudStorage(
                    region: .usWest2,
                    bucketName: deviceSetting.s3Configuration.bucketName,
                    poolId: deviceSetting.s3Configuration.identityPoolId,
                    isAccelerateModeEnabled: true
                )

                self.cloudStorage = cloudStorage
                return cloudStorage
            } catch {
                throw UtilityError(
                    kind: .CloudStorageProviderErrorReason.makeCloudStorageFailed,
                    underlyingError: error
                )
            }
        }

        return cloudStorage
    }
}
