//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A collection of localized strings used throughout the camera module.
///
/// `Localizations` provides a centralized location for all user-facing text strings
/// that need to be localized. Each property represents a specific UI element or
/// message that users will see in the camera interface.
struct Localizations {
    // MARK: - C

    /// Cancel copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Cancel */
    ///
    /// - Returns: A localized string.
    static let cancel = NSLocalizedString("Cancel", bundle: .module, comment: "")

    // MARK: - D

    /// Discard copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Discard */
    ///
    /// - Returns: A localized string.
    static let discard = NSLocalizedString("Discard", bundle: .module, comment: "")

    /// Discard Message copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Would you like to discard all videos and images? */
    ///
    /// - Returns: A localized string.
    static let discardMessage = NSLocalizedString("DiscardMessage", bundle: .module, comment: "")

    // MARK: - E

    /// Exit copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Exit */
    ///
    /// - Returns: A localized string.
    static let exit = NSLocalizedString("Exit", bundle: .module, comment: "")

    // MARK: - M

    /// Max clip duration reached copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* You’ve reached the video recording time limit.. */
    ///
    /// - Returns: A localized string.
    static let maxClipDurationReached = NSLocalizedString(
        "MaxClipDurationReached",
        bundle: .module,
        comment: ""
    )

    /// Max number of clips reached copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* You have reached the maximum number of videos for this session. */
    ///
    /// - Returns: A localized string.
    static let maxNumberOfClipsReached = NSLocalizedString(
        "MaxNumberOfClipsReached",
        bundle: .module,
        comment: ""
    )

    /// Max number of pictures reached copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* You have reached the maximum number of pictures for this session. */
    ///
    /// - Returns: A localized string.
    static let maxNumberOfPicturesReached = NSLocalizedString(
        "MaxNumberOfPicturesReached",
        bundle: .module,
        comment: ""
    )

    // MARK: - O

    /// Open Settings copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Open Settings */
    ///
    /// - Returns: A localized string.
    static let openSettings = NSLocalizedString("OpenSettings", bundle: .module, comment: "")

    // MARK: - P

    /// Permission Disclaimer copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* This lets you use the camera and microphone to take photos and record videos seamlessly. */
    ///
    /// - Returns: A localized string.
    static let permissionDisclaimer = NSLocalizedString("PermissionDisclaimer", bundle: .module, comment: "")

    /// Permission Message copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Allow the App to access your camera and microphone */
    ///
    /// - Returns: A localized string.
    static let permissionMessage = NSLocalizedString("PermissionMessage", bundle: .module, comment: "")
}
