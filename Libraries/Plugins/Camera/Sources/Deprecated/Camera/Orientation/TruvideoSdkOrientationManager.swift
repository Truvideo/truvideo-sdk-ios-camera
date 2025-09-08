//
//  TruvideoOrientationManager.swift
//  TruvideoSdkShared
//
//  Created by Victor Arana on 11/11/24.
//

import Combine
import UIKit

enum CameraInterface {
    case uikit, swiftui
}

class TruvideoSdkOrientationManager: TruvideoOrientationInterface {

    // - MARK: Class name
    let className = String(describing: TruvideoSdkOrientationManager.self)

    static let shared = TruvideoSdkOrientationManager()

    // MARK: - Physical device orientation
    private let physicalProvider: OrientationProvider
    private let validPhysicalOrientations = [
        UIDeviceOrientation.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight,
    ]
    private let physicalSubject = PassthroughSubject<UIDeviceOrientation, Never>()
    /// Emits physical device orientation updates to other `Truideo Modules`
    var physicalOrientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        physicalSubject.eraseToAnyPublisher()
    }

    // MARK: - App orientation
    private let appProvider: OrientationProvider
    private(set) var supportedAppOrientations = [UIDeviceOrientation]()
    private let appSubject = PassthroughSubject<UIDeviceOrientation, Never>()
    /// Emits app orientation updates to other modules `Truideo Modules`
    var appOrientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        appSubject.eraseToAnyPublisher()
    }

    private var previousAppOrientation: UIInterfaceOrientationMask?

    private var store = Set<AnyCancellable>()

    private weak var appDelegate: TruvideoSdkCameraAppDelegate?

    var appIsActive: Bool

    var cameraInterface: CameraInterface = .uikit

    init(
        physicalOrientationProvider: OrientationProvider = CoreMotionOrientationProvider(),
        appOrientationProvider: OrientationProvider = AppOrientationProvider()
    ) {
        physicalProvider = physicalOrientationProvider
        appProvider = appOrientationProvider
        appIsActive = false

        guard let orientations = Bundle.main.infoDictionary?["UISupportedInterfaceOrientations"] as? [String] else {
            fatalError("Could not load supported orientations")
        }

        supportedAppOrientations = orientations.map({ orientation in
            switch orientation {
            case "UIInterfaceOrientationPortrait":
                return .portrait
            case "UIInterfaceOrientationLandscapeLeft":
                return .landscapeLeft
            case "UIInterfaceOrientationLandscapeRight":
                return .landscapeRight
            case "UIInterfaceOrientationPortraitUpsideDown":
                return .portraitUpsideDown
            default:
                return .unknown
            }
        })

        physicalProvider.orientationPublisher
            .sink { [weak self] orientation in
                self?.handlePhysicalOrientationChange(to: orientation)
            }.store(in: &store)

        appProvider.orientationPublisher
            .sink { [weak self] orientation in
                self?.handleAppOrientationChange(to: orientation)
            }.store(in: &store)
    }

    private func handlePhysicalOrientationChange(to newOrientation: UIDeviceOrientation) {
        guard appIsActive, validPhysicalOrientations.contains(newOrientation) else {
            return
        }

        physicalSubject.send(newOrientation)
    }

    private func handleAppOrientationChange(to newOrientation: UIDeviceOrientation) {
        guard appIsActive, supportedAppOrientations.contains(newOrientation) else {
            return
        }

        appSubject.send(newOrientation)
    }

    func lockToOrientation(_ orientation: UIInterfaceOrientationMask) -> Bool {
        switch cameraInterface {
        case .uikit:
            return false
        case .swiftui:
            guard let appDelegate else {
                dprint(className, "orientation was not [LOCKED] in \(orientation.title)")
                return false
            }
            dprint(className, "orientation was [LOCKED] in \(orientation.title)")
            previousAppOrientation = appDelegate.orientationLock
            appDelegate.orientationLock = orientation
            return true
        }
    }

    func unlockAppOrientation() {
        guard let appDelegate, let previousAppOrientation else {
            dprint(className, "orientation was not [UNLOCKED]")
            return
        }
        dprint(className, "orientation was [UNLOCKED]")
        appDelegate.orientationLock = previousAppOrientation
        self.previousAppOrientation = nil
    }

    func configureTruvideoSdkAppDelegate(_ appDelegate: TruvideoSdkCameraAppDelegate) {
        dprint(className, "camera app delegate was [CONFIGURED]")
        self.appDelegate = appDelegate
    }

    func stopOrientationTracking() {
        appIsActive = false
        if let appProvider = appProvider as? AppOrientationProvider {
            appProvider.stopTracking()
        }
        store.removeAll()
    }

    func startOrientationTracking() {
        appIsActive = true
    }
}
