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
    // MARK: - A

    /// Error message when another app is using the audio copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Recording is not available because another app is using the microphone. Please close it and try again. */
    ///
    /// - Returns: A localized string.
    static let anotherAppIsUsingMicrophone = NSLocalizedString(
        "AnotherAppIsUsingMicrophone",
        bundle: .module,
        comment: ""
    )

    // MARK: - C

    /// Cancel copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Cancel */
    ///
    /// - Returns: A localized string.
    static let cancel = NSLocalizedString("Cancel", bundle: .module, comment: "")

    /// Continue copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Continue */
    ///
    /// - Returns: A localized string.
    static let continueText = NSLocalizedString("Continue", bundle: .module, comment: "")

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

    // MARK: - F

    /// Failed to set preset copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Failed to set preset. Try a lower resolution or frame rate */
    ///
    /// - Returns: A localized string.
    static let failedToSetPreset = NSLocalizedString("FailedToSetPreset", bundle: .module, comment: "")

    /// FHD copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* FHD */
    ///
    /// - Returns: A localized string.
    static let fhd = NSLocalizedString("FHD", bundle: .module, comment: "")

    // MARK: - H

    // swiftlint:disable identifier_name
    /// HD copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* HD */
    ///
    /// - Returns: A localized string.
    static let hd = NSLocalizedString("HD", bundle: .module, comment: "")
    // swiftlint:enable identifier_name

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

    /// Preset not supported copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /*  Preset not supported on this device */
    ///
    /// - Returns: A localized string.
    static let presetNotSupported = NSLocalizedString("PresetNotSupported", bundle: .module, comment: "")

    // MARK: - R

    /// Resolutions copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Resolutions */
    ///
    /// - Returns: A localized string.
    static let resolutions = NSLocalizedString("Resolutions", bundle: .module, comment: "")

    // MARK: - S

    // swiftlint:disable identifier_name
    /// SD copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* SD */
    ///
    /// - Returns: A localized string.
    static let sd = NSLocalizedString("SD", bundle: .module, comment: "")
    // swiftlint:enable identifier_name

    /// Sign in to continue copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Sign in to continue */
    ///
    /// - Returns: A localized string.
    static let signInToContinue = NSLocalizedString("SignInToContinue", bundle: .module, comment: "")

    /// Sign in to use camera copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Sign in to use the camera and microphone to take photos and record videos */
    ///
    /// - Returns: A localized string.
    static let signInToUseCamera = NSLocalizedString("SignInToUseCamera", bundle: .module, comment: "")

    // MARK: - U

    /// SD copy.
    ///
    /// In en, this message translates to:
    ///
    ///     /* Unknown */
    ///
    /// - Returns: A localized string.
    static let unknown = NSLocalizedString("Unknown", bundle: .module, comment: "")
}
