//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import TruVideoApi
import UIKit

// swiftlint:disable identifier_name
/// A context object containing device and system information for authentication and telemetry.
///
/// `Context` provides a standardized way to capture device and system information that is
/// used during authentication processes and telemetry reporting. This information helps
/// identify the client device and provides context for server-side processing.
///
/// - Note: The context is automatically populated with current device information.
/// - Important: This information is used for authentication and should be accurate.
/// - Warning: Do not modify the context values as they are used for security purposes.
public struct Context: Codable, Sendable {
    /// The device manufacturer brand.
    ///
    /// Always set to `"Apple"` for iOS devices and other Apple platforms.
    public let brand: String

    /// The specific device model identifier.
    ///
    /// Provides detailed hardware information (e.g., `"iPhone16,2"` for iPhone 15 Pro).
    /// This identifier uniquely identifies the hardware model of the device.
    public let model: String

    /// The operating system name.
    ///
    /// Identifies the platform the app is running on (e.g., `"iOS"`, `"macOS"`, `"tvOS"`).
    public let os: String

    /// The operating system version.
    ///
    /// Provides version-specific information (e.g., `"17.2"`, `"14.1"`) for
    /// compatibility checking and feature detection.
    public let osVersion: String

    /// The Unix timestamp when the context was created.
    ///
    /// Represents the number of seconds since January 1, 1970, UTC.
    /// Used for request timing, caching, and temporal analysis.
    public let timestamp: Int

    // MARK: - Initializer

    /// Creates a new context with current device and system information.
    ///
    /// This initializer automatically populates all properties with current
    /// device information, system details, and timestamp.
    public init() {
        self.brand = "Apple"
        self.model = UIDevice.current.modelIdentifier
        self.os = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        self.timestamp = Int(Date().timeIntervalSince1970)
    }
    
    // MARK: - Instance methods
    
    /// Converts the current device information into a TruVideoApi.Context object.
    ///
    /// This function creates a new `TruVideoApi.Context` instance by mapping the current
    /// device properties to the corresponding context fields. It serves as a bridge
    /// between the local device information model and the API context structure
    /// used for video processing requests.
    ///
    /// - Returns: A `TruVideoApi.Context` object containing the current device
    ///   information mapped to the API context structure.
    func toContext() -> TruVideoApi.Context {
        TruVideoApi.Context(brand: brand, model: model, os: os, osVersion: osVersion, timestamp: timestamp)
    }
}
// swiftlint:enable identifier_name
