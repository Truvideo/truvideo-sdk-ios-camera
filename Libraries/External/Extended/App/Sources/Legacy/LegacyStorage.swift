//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import StorageKit
internal import TruVideoApi
internal import Utilities

/// A protocol that defines the interface for storing authentication data in legacy storage systems.
///
/// The `LegacyStorage` protocol provides a standardized way to store authentication
/// tokens and API keys in legacy storage implementations. It abstracts the storage
/// mechanism, allowing different storage backends to be used while maintaining
/// a consistent interface for authentication data persistence.
///
/// This protocol is typically used during migration processes or when working
/// with older storage systems that need to maintain compatibility with existing
/// authentication workflows.
protocol LegacyStorage {
    /// Clears all stored authentication data from the legacy storage system.
    ///
    /// This method removes all authentication tokens, API keys, and device settings
    /// that have been stored in the legacy storage system. It performs a complete
    /// cleanup of all authentication-related data, effectively signing out the user
    /// from the legacy authentication system.
    func clear()
    
    /// Stores an authentication token and API key in the legacy storage system.
    ///
    /// This method persists the provided authentication token and API key
    /// using the legacy storage mechanism. The implementation should handle
    /// serialization, validation, and any storage-specific error conditions.
    ///
    /// - Parameters:
    ///   - token: The authentication token to be stored
    ///   - apiKey: The API key to be stored alongside the token
    /// - Throws: Various errors depending on the specific storage implementation
    func set(_ token: AuthToken, apiKey: String) throws
    
    /// Stores the device setting in the legacy storage system.
    ///
    /// This function persists device-specific configuration and settings to the legacy
    /// storage system by encoding the `DeviceSetting` object to JSON format and storing
    /// it as a string in UserDefaults. The function handles the complete serialization
    /// process and provides error handling for encoding failures.
    ///
    /// - Parameter deviceSetting: The authentication token to be stored
    /// - Throws: Various errors depending on the specific storage implementation
    func set(_ deviceSetting: DeviceSetting) throws
}

/// A concrete implementation of `LegacyStorage` that uses UserDefaults for persistence.
///
/// The `LegacySessionStorage` struct provides a UserDefaults-based implementation
/// of the `LegacyStorage` protocol, specifically designed to store authentication
/// tokens and API keys in a legacy storage format. It handles the serialization
/// of authentication data and persists it using the UserDefaults system with
/// a specific suite name for organization.
///
/// This implementation is typically used during migration processes or when
/// maintaining compatibility with existing authentication storage systems.
struct LegacySessionStorage: LegacyStorage {
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initializer
    
    /// Creates a new legacy session storage instance with the specified UserDefaults.
    ///
    /// This initializer sets up the legacy session storage with a configurable
    /// UserDefaults instance. By default, it uses a custom UserDefaults suite
    /// named "truvideo-sdk-common-settings" to isolate SDK settings from the
    /// application's main UserDefaults, providing better organization and
    /// preventing potential conflicts with app-specific settings.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use for storage.
    init(userDefaults: UserDefaults? = UserDefaults(suiteName: "truvideo-sdk-common-settings")) {
        self.userDefaults = userDefaults ?? .standard
    }
    
    // MARK: - LegacyStorage
    
    /// Clears all stored authentication data from the legacy storage system.
    ///
    /// This method removes all authentication tokens, API keys, and device settings
    /// that have been stored in the legacy storage system. It performs a complete
    /// cleanup of all authentication-related data, effectively signing out the user
    /// from the legacy authentication system.
    func clear() {
        userDefaults.removeObject(forKey: "truvideo-sdk-api-key")
        userDefaults.removeObject(forKey: "truvideo-sdk-authentication")
        userDefaults.removeObject(forKey: "truvideo-sdk-settings")
    }
    
    /// Stores an authentication token and API key in the legacy storage system.
    ///
    /// This method persists the provided authentication token and API key
    /// using the legacy storage mechanism. The implementation should handle
    /// serialization, validation, and any storage-specific error conditions.
    ///
    /// - Parameters:
    ///   - token: The authentication token to be stored
    ///   - apiKey: The API key to be stored alongside the token
    /// - Throws: Various errors depending on the specific storage implementation
    func set(_ token: AuthToken, apiKey: String) throws {
        let rawData = try JSONEncoder().encode(token)
        
        if let rawToken = String(data: rawData, encoding: .utf8) {
            userDefaults.set(apiKey, forKey: "truvideo-sdk-api-key")
            userDefaults.set(rawToken, forKey: "truvideo-sdk-authentication")
        } else {
            throw UtilityError(kind: .unknown, failureReason: "Unable to create string representation of the token.")
        }
    }
    
    /// Stores the device setting in the legacy storage system.
    ///
    /// This function persists device-specific configuration and settings to the legacy
    /// storage system by encoding the `DeviceSetting` object to JSON format and storing
    /// it as a string in UserDefaults. The function handles the complete serialization
    /// process and provides error handling for encoding failures.
    ///
    /// - Parameter deviceSetting: The authentication token to be stored
    /// - Throws: Various errors depending on the specific storage implementation
    func set(_ deviceSetting: DeviceSetting) throws {
        let rawData = try JSONEncoder().encode(deviceSetting)
        
        if let rawSettings = String(data: rawData, encoding: .utf8) {
            userDefaults.set(rawSettings, forKey: "truvideo-sdk-settings")
        } else {
            throw UtilityError(kind: .unknown, failureReason: "Unable to create string representation of the settings.")
        }
    }
}
