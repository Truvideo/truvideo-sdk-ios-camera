//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
internal import InternalUtilities
import Networking
import Utilities

/// A protocol that defines the interface for retrieving device settings from the TruVideo API.
///
/// This protocol provides a standardized way to fetch device-specific configuration
/// and settings from the TruVideo backend. It requires authentication and returns
/// device settings that can be used to configure the SDK behavior.
public protocol DeviceSettingsResource: Sendable {
    /// Retrieves the current device settings from the TruVideo API.
    ///
    /// This method fetches device-specific configuration and settings that are
    /// associated with the authenticated device. The settings may include
    /// feature flags, configuration parameters, and device-specific preferences.
    ///
    /// ## Prerequisites
    ///
    /// - The user must be authenticated before calling this method
    /// - A valid authentication session must be available
    ///
    /// - Returns: The device settings for the authenticated device
    /// - Throws: An error if the request fails or the user is not authenticated
    func retrieve() async throws(UtilityError) -> DeviceSetting
}

/// A concrete implementation of the `DeviceSettingsResource` protocol.
///
/// This struct provides the actual implementation for retrieving device settings
/// from the TruVideo API. It uses dependency injection to access the API environment,
/// network session, and session manager for authentication.
public struct DeviceSettingsResourceImpl: DeviceSettingsResource {
    // MARK: - Dependencies

    @Dependency(\.environment)
    private var environment: Environment

    @Dependency(\.session)
    private var session: any Session

    @Dependency(\.sessionManager)
    private var sessionManager: any SessionManager

    // MARK: - Initializer

    /// Creates a new instance of the `DeviceSettingsResourceImpl`.
    public init() {}

    // MARK: - DeviceSettingsResource

    /// Retrieves the current device settings from the TruVideo API.
    ///
    /// This method fetches device-specific configuration and settings that are
    /// associated with the authenticated device. The settings may include
    /// feature flags, configuration parameters, and device-specific preferences.
    ///
    /// ## Prerequisites
    ///
    /// - The user must be authenticated before calling this method
    /// - A valid authentication session must be available
    ///
    /// - Returns: The device settings for the authenticated device
    /// - Throws: An error if the request fails or the user is not authenticated
    public func retrieve() async throws(UtilityError) -> DeviceSetting {
        guard let authToken = sessionManager.currentSession?.authToken else {
            throw UtilityError(
                kind: .TruVideoApiErrorReason.unauthenticated,
                failureReason: "No valid authentication session found. User must authenticate first."
            )
        }

        do {
            return try await session.request(
                environment.baseURL.appending("/api/device/\(authToken.id)/settings"),
                method: .get,
                cachePolicy: .returnCacheDataElseLoad
            )
            .validate(RequestValidator.validate)
            .validate()
            .serializing(DeviceSetting.self)
            .result
            .get()
        } catch {
            throw UtilityError(kind: .TruVideoApiErrorReason.deviceSettingsRetrivalFailed, underlyingError: error)
        }
    }
}
