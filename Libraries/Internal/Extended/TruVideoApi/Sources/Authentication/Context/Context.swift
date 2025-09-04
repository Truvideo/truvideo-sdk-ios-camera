//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit
import Utilities

// swiftlint:disable identifier_name
/// A context object containing device and system information for authentication and telemetry.
///
/// `Context` provides a standardized way to capture device and system information that is
/// used during authentication processes and telemetry reporting. This information helps
/// identify the client device and provides context for server-side processing.
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
    ///
    /// - Parameters:
    ///    - brand: The device manufacturer brand.
    ///    - model: The specific device model identifier.
    ///    - os: The operating system name.
    ///    - osVersion: The operating system version.
    ///    - timestamp The Unix timestamp when the context was created.
    public init(brand: String, model: String, os: String, osVersion: String, timestamp: Int) {
        self.brand = brand
        self.model = model
        self.os = os
        self.osVersion = osVersion
        self.timestamp = timestamp
    }
}
// swiftlint:enable identifier_name
