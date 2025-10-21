//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A collection of design system icons used throughout the camera interface.
///
/// `DSIcons` provides centralized access to all icon assets used in the camera design system,
/// including both SF Symbols and custom bundle images. This struct ensures consistency
/// in icon usage across the camera interface and makes it easy to maintain and update
/// icon references in a single location.
///
/// ## Icon Types
///
/// The collection includes:
/// - **SF Symbols**: System-provided icons like bolt, camera, and play controls
/// - **Action Icons**: Play, pause, and navigation controls
/// - **Media Icons**: Camera and photo-related imagery
///
/// ## Usage
///
/// ```swift
/// // Use SF Symbol icons
/// Image(systemName: "bolt.fill")
/// // vs
/// DSIcons.boltFill
///
/// // Use custom bundle icons
/// DSIcons.flipCameraIcon
/// ```
public enum DSIcons {
    /// Represents a filled lightning bolt, typically used for power or energy-related actions.
    static let boltFill = Image(systemName: "bolt.fill")

    /// Represents a crossed-out lightning bolt, typically used to indicate disabled
    /// or unavailable power-related functionality.
    static let boltSlashFill = Image(systemName: "bolt.slash.fill")

    /// Represents a camera device, used for camera-related actions and indicators.
    static let camera = Image(systemName: "camera")

    /// Represents the camera flip action, loaded from the app's custom image assets.
    static let cameraTrianglehead = Image("flip-camera", bundle: Bundle(for: BundleLocator.self))

    /// Represents the rear iPhone camera, typically used for device-specific camera indicators or settings related to
    /// camera hardware.
    static let iphoneCamera = Image(systemName: "iphone.rear.camera")

    /// Represents a lock icon for security and authentication-related actions.
    static let lock = Image(systemName: "lock")

    /// Represents the pause action, typically used for media playback controls.
    static let pause = Image(systemName: "pause.fill")

    /// Represents a photo or image, used for photo-related actions and indicators.
    static let photo = Image(systemName: "photo.fill")

    /// Play icon from SF Symbols.
    ///
    /// Represents the play action, typically used for media playback controls.
    static let play = Image(systemName: "play.fill")

    /// A system trash icon for delete actions.
    static let trash = Image(systemName: "trash")

    /// Represents a video camera, typically used to indicate video recording
    /// functionality or camera mode selection.
    static let video = Image(systemName: "video")

    /// Represents a viewfinder image, typically used to indicate a camera focus or scanning interface.
    static let viewFinder = Image("tap-to-focus", bundle: Bundle(for: BundleLocator.self))

    /// Represents a close or cancel action, typically used for dismissing views or canceling operations.
    static let xmark = Image(systemName: "xmark")
}
