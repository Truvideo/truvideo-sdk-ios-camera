//
//  AppOrientationProvider.swift
//  TruvideoSdkShared
//
//  Created by Victor Arana on 12/5/24.
//

import Combine
import UIKit

class AppOrientationProvider: OrientationProvider {

    private let subject = PassthroughSubject<UIDeviceOrientation, Never>()
    var orientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        subject.eraseToAnyPublisher()
    }

    let isTrackingOrientationChanges: Bool = true

    private var orientationObserver: NSObjectProtocol?

    init() {
        // Enable orientation notifications
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleOrientationChange()
        }
    }

    deinit {
        cleanup()
    }

    private func cleanup() {
        if let observer = orientationObserver {
            NotificationCenter.default.removeObserver(observer)
            orientationObserver = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    func stopTracking() {
        cleanup()
    }

    @objc private func handleOrientationChange() {
        subject.send(.currentAppOrientation())
    }
}

extension UIDeviceOrientation {
    static func currentAppOrientation() -> UIDeviceOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .portrait
        }
        let interfaceOrientation = windowScene.interfaceOrientation

        switch interfaceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }

    var title: String {
        switch self {
        case .portrait:
            return "PORTRAIT"
        case .portraitUpsideDown:
            return "PORTRAIT-UPSIDE-DOWN"
        case .landscapeLeft:
            return "LANDSCAPE-LEFT"
        case .landscapeRight:
            return "LANDSCAPE-RIGHT"
        default:
            return "UNKNOWN"
        }
    }
}
