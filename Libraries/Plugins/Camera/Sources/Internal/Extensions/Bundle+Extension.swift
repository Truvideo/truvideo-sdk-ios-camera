//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    // MARK: - Computed Properties

    /// Returns the supported interface orientations for the bundle.
    ///
    /// This computed property reads the `UISupportedInterfaceOrientations` key from the bundle's
    /// Info.plist file and converts the string-based orientation values into a `UIInterfaceOrientationMask`.
    /// It provides a convenient way to access supported orientations programmatically without
    /// manually parsing the Info.plist dictionary.
    ///
    /// ## Info.plist Mapping
    ///
    /// The property maps Info.plist string values to `UIInterfaceOrientationMask` values:
    /// - `"UIInterfaceOrientationPortrait"` → `.portrait`
    /// - `"UIInterfaceOrientationPortraitUpsideDown"` → `.portraitUpsideDown`
    /// - `"UIInterfaceOrientationLandscapeLeft"` → `.landscapeRight` (note: orientation mapping)
    /// - `"UIInterfaceOrientationLandscapeRight"` → `.landscapeLeft` (note: orientation mapping)
    ///
    /// ## Important Note
    ///
    /// There's an orientation mapping correction in the landscape orientations:
    /// - Info.plist `"UIInterfaceOrientationLandscapeLeft"` maps to `.landscapeRight`
    /// - Info.plist `"UIInterfaceOrientationLandscapeRight"` maps to `.landscapeLeft`
    ///
    /// This correction accounts for the difference between Info.plist naming convention
    /// and the actual interface orientation behavior in iOS.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bundle = Bundle.main
    /// let orientations = bundle.supportedOrientations
    ///
    /// if orientations.contains(.portrait) {
    ///     print("Portrait orientation is supported")
    /// }
    ///
    /// if orientations.contains(.landscapeLeft) {
    ///     print("Landscape left orientation is supported")
    /// }
    /// ```
    var supportedOrientations: UIInterfaceOrientationMask {
        guard let orientations = infoDictionary?["UISupportedInterfaceOrientations"] as? [String] else {
            return []
        }

        var supportedOrientations: UIInterfaceOrientationMask = []

        for orientation in orientations {
            switch orientation {
            case "UIInterfaceOrientationPortrait":
                supportedOrientations.insert(.portrait)

            case "UIInterfaceOrientationPortraitUpsideDown":
                supportedOrientations.insert(.portraitUpsideDown)

            case "UIInterfaceOrientationLandscapeLeft":
                supportedOrientations.insert(.landscapeLeft)

            case "UIInterfaceOrientationLandscapeRight":
                supportedOrientations.insert(.landscapeRight)

            default:
                continue
            }
        }

        return supportedOrientations
    }

    // MARK: - Static Properties

    /// The bundle containing the current module's resources and metadata.
    static let module = Bundle(for: BundleLocator.self)
}
