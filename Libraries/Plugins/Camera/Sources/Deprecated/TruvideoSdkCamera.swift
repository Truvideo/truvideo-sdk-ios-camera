//
// Created by TruVideo on 12/15/23.
// Copyright © 2023 TruVideo. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

/// The global instance of `TruvideoSdkCamera`, providing access to camera functionalities.
///
/// `TruvideoSdkCamera` conforms to both:
/// - ``TruvideoSdkCameraInterface``: Provides methods to configure and interact with the camera.
/// - ``TruvideoSdkCameraEventsInterface``: Manages event observers for camera interactions.
///
/// ## Example Usage
/// ```swift
/// let cameraInfo = TruvideoSdkCamera.getTruvideoSdkCameraInformation()
/// ```
public let TruvideoSdkCamera: TruvideoSdkCameraInterface & TruvideoSdkCameraEventsInterface =
    TruvideoSdkCameraInterfaceImp()

/// Provides a shared instance for accessing `TruvideoSdkCamera` functionalities.
///
/// `TruvideoSdkCameraProvider` acts as a singleton, offering a centralized way to access the **Truvideo Camera SDK**.
///
/// ## Example Usage
/// ```swift
/// let cameraInstance = TruvideoSdkCameraProvider.shared
/// let cameraInfo = cameraInstance.getTruvideoSdkCameraInformation()
/// ```
@objc public class TruvideoSdkCameraProvider: NSObject {
    /// The shared instance for accessing `TruvideoSdkCamera` functionalities.
    ///
    /// This instance provides access to all SDK camera features.
    @objc public static let shared: TruvideoSdkCameraInterface = TruvideoSdkCamera
}

/// Defines the interface for accessing `TruvideoSdkCamera` functionalities.
///
/// The `TruvideoSdkCameraInterface` provides access to core camera functionality, including
/// retrieving available cameras and configuring the SDK.
///
/// ## Example Usage
/// ```swift
/// let sdkCamera = TruvideoSdkCameraProvider.shared
/// sdkCamera.configureTruvideoSdkAppDelegate(myAppDelegate)
/// ```
@objc public protocol TruvideoSdkCameraInterface {
    /// Provides the main camera delegate, responsible for handling SDK camera operations.
    @objc var camera: TruvideoSdkCameraDelegate { get }

    /// Configures the Truvideo SDK with an application delegate.
    ///
    /// This method should be called during application setup to **initialize the camera SDK**.
    ///
    /// - Parameter appDelegate: The `TruvideoSdkCameraAppDelegate` instance handling app-wide camera events.
    @objc func configureTruvideoSdkAppDelegate(_ appDelegate: TruvideoSdkCameraAppDelegate)
}

/// Defines the interface for handling camera-related events.
///
/// `TruvideoSdkCameraEventsInterface` provides access to an event observer, allowing the application
/// to listen for **real-time camera-related events**.
///
/// ## Example Usage
/// ```swift
/// let eventObserver = TruvideoSdkCamera.events
/// ```
public protocol TruvideoSdkCameraEventsInterface {
    /// Provides access to the event observer that listens for camera-related actions.
    var events: TruvideoSdkCameraEventObserver { get }
}

/// Defines the delegate responsible for retrieving camera information.
///
/// The `TruvideoSdkCameraDelegate` allows applications to fetch camera details, such as available lenses,
/// supported resolutions, and hardware capabilities.
///
/// ## Example Usage
/// ```swift
/// let cameraInfo = TruvideoSdkCameraProvider.shared.camera.getTruvideoSdkCameraInformation()
/// ```
@objc public protocol TruvideoSdkCameraDelegate {
    /// Retrieves all available camera information for both **front** and **back** cameras.
    ///
    /// - Returns: A ``TruvideoSdkCameraInformation`` object containing detailed camera specifications.
    @objc func getTruvideoSdkCameraInformation() -> TruvideoSdkCameraInformation
}
