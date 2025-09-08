//
// Created by TruVideo on 12/9/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import UIKit

/// Defines the application delegate for handling camera-related configurations.
///
/// `TruvideoSdkCameraAppDelegate` extends `UIApplicationDelegate` and provides control over **interface orientation lock** settings.
///
/// ## Overview
/// This protocol is responsible for:
/// - **Managing the orientation lock** for the camera.
/// - **Defining supported interface orientations** for the application.
///
/// ## Example Usage
/// ```swift
/// class AppDelegate: UIResponder, TruvideoSdkCameraAppDelegate {
///     var orientationLock: UIInterfaceOrientationMask = .portrait
///
///     func application(
///         _ application: UIApplication,
///         supportedInterfaceOrientationsFor window: UIWindow?
///     ) -> UIInterfaceOrientationMask {
///         return orientationLock
///     }
/// }
/// ```
@objc public protocol TruvideoSdkCameraAppDelegate: NSObjectProtocol, UIApplicationDelegate {
    /// The current orientation lock for the application.
    @objc var orientationLock: UIInterfaceOrientationMask { get set }

    /// Determines the supported interface orientations for the application.
    ///
    /// This method allows the app to specify **which orientations** are permitted for a given window.
    ///
    /// - Parameters:
    ///   - application: The running application instance.
    ///   - window: The main application window.
    /// - Returns: A `UIInterfaceOrientationMask` specifying the supported orientations.
    @objc func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask
}
