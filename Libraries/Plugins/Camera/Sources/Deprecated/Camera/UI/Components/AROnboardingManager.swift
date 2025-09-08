//
// Created by TruVideo on 21/07/25.
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Manages onboarding state specifically for AR Camera renderer modes
final class AROnboardingManager {

    // MARK: - Properties

    private let userDefaults = UserDefaults.standard

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let hasSeenPinObjectsModeOnboarding = "TruvideoSdk.ARCamera.PinObjectsMode.HasSeenOnboarding"
        static let hasSeenRulerModeOnboarding = "TruvideoSdk.ARCamera.RulerMode.HasSeenOnboarding"
        static let hasSeenNoneModeOnboarding = "TruvideoSdk.ARCamera.NoneMode.HasSeenOnboarding"
    }

    // MARK: - Singleton

    static let shared = AROnboardingManager()

    // MARK: - Public Methods

    /// Checks if the user has seen the onboarding for a specific AR renderer mode
    func hasSeenOnboardingForMode(_ mode: ARRendererMode) -> Bool {
        let key = getUserDefaultsKeyForMode(mode)
        let hasSeenOnboarding = userDefaults.bool(forKey: key)
        return hasSeenOnboarding
    }

    /// Marks the onboarding for a specific AR renderer mode as seen
    func markOnboardingAsSeenForMode(_ mode: ARRendererMode) {
        let key = getUserDefaultsKeyForMode(mode)
        userDefaults.set(true, forKey: key)
    }

    /// Checks if onboarding should be shown for the given mode
    func shouldShowOnboardingForMode(_ mode: ARRendererMode) -> Bool {
        !hasSeenOnboardingForMode(mode)
    }

    /// Resets all AR onboarding preferences (internal for testing purposes)
    internal func resetAROnboardingPreferences() {
        userDefaults.removeObject(forKey: Keys.hasSeenPinObjectsModeOnboarding)
        userDefaults.removeObject(forKey: Keys.hasSeenRulerModeOnboarding)
        userDefaults.removeObject(forKey: Keys.hasSeenNoneModeOnboarding)
    }

    // MARK: - Private Methods

    private func getUserDefaultsKeyForMode(_ mode: ARRendererMode) -> String {
        switch mode {
        case .pinObjects:
            return Keys.hasSeenPinObjectsModeOnboarding
        case .ruler:
            return Keys.hasSeenRulerModeOnboarding
        case .none:
            return Keys.hasSeenNoneModeOnboarding
        }
    }
}
