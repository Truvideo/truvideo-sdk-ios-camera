//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Combine
internal import DI
import Foundation
import SwiftUI
import TruvideoSdk
import UIKit

/// A specialized hosting controller responsible for displaying and managing the SwiftUI-based camera interface.
///
/// This controller encapsulates a `CameraView` and coordinates its interaction with UIKit,
/// including orientation handling and Combine-based observation of the camera's internal state.
///
/// The controller dynamically updates its supported interface orientations based on the camera's
/// operational state — for example, locking to landscape while recording and restoring the system’s
/// supported orientations when paused or finished.
final class CameraHostingController: UIHostingController<CameraView> {
    // MARK: - Private Properties

    private var _supportedInterfaceOrientations = UIInterfaceOrientationMask.allButUpsideDown
    private var cancellables = Set<AnyCancellable>()
    private let onDismiss: () -> Void

    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    private var orientationMonitor: OrientationMonitor

    // MARK: - Overridden Properties

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        _supportedInterfaceOrientations
    }

    // MARK: - Initializers

    /// Creates a new camera hosting controller with a given configuration and completion handler.
    ///
    /// The initializer sets up the SwiftUI `CameraView` using the provided `CameraViewModel`.
    /// It also subscribes to orientation changes via the view model’s `state` publisher.
    ///
    /// - Parameters:
    ///   - configuration: The camera configuration containing settings and
    ///     preferences used to initialize the camera experience.
    ///   - truVideoSdk: The TruVideo SDK instance used to perform camera-related
    ///     operations. Defaults to the shared `TruvideoSdk` instance.
    ///   - onComplete: A closure invoked when the camera flow finishes with a
    ///     `TruvideoSdkCameraResult` (for example, after capturing or confirming
    ///     media). Use this to handle the final result of the camera session.
    ///   - onDismiss: A closure invoked when the hosting controller is dismissed,
    ///     regardless of whether the camera flow completed successfully or was
    ///     cancelled. Defaults to an empty closure and is typically used to keep
    ///     external presentation state (such as a `Binding<Bool> isPresented`)
    ///     in sync with the UI.
    init(
        configuration: TruvideoSdkCameraConfiguration,
        truVideoSdk: TruVideoSDK = TruvideoSdk,
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.onDismiss = onDismiss

        let viewModel = CameraViewModel(configuration: configuration, truVideoSdk: truVideoSdk, onComplete: onComplete)
        let rootView = CameraView(viewModel: viewModel)

        super.init(rootView: rootView)

        if truVideoSdk.isAuthenticated {
            let preferredOrientation = configuration.orientation.map(UIInterfaceOrientationMask.init(from:))
            let supportedInterfaceOrientations = preferredOrientation ?? Bundle.main.supportedOrientations

            _supportedInterfaceOrientations = supportedInterfaceOrientations

            if preferredOrientation == nil {
                orientationMonitor.startMonitoring()
            }

            viewModel.$state
                .sink { [weak self] status in
                    guard let self else { return }

                    defer {
                        if #available(iOS 16.0, *) {
                            setNeedsUpdateOfSupportedInterfaceOrientations()
                        }
                    }

                    guard [.paused, .running].contains(status) else {
                        _supportedInterfaceOrientations = supportedInterfaceOrientations
                        return
                    }

                    if let orientation = view.window?.windowScene?.interfaceOrientation {
                        _supportedInterfaceOrientations = UIInterfaceOrientationMask(from: orientation)
                    }
                }
                .store(in: &cancellables)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods

    override func viewDidDisappear(_ animated: Bool) {
        onDismiss()
        orientationMonitor.stopMonitoring()

        super.viewDidDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}

extension UIInterfaceOrientationMask {
    /// Creates an interface orientation mask from a camera-specific orientation.
    ///
    /// This initializer maps a `TruvideoSdkCameraInterfaceOrientation` value to the
    /// corresponding `UIInterfaceOrientationMask` used by UIKit for rotation and
    /// layout decisions.
    ///
    /// Use this when you need to express the camera’s desired orientation in terms
    /// of UIKit’s orientation mask system (for example, when returning
    /// `supportedInterfaceOrientations` from a view controller).
    ///
    /// - Parameter orientation: The camera interface orientation to convert into
    ///   a `UIInterfaceOrientationMask`.
    fileprivate init(from orientation: TruvideoSdkCameraOrientation) {
        self =
            switch orientation {
            case .portrait:
                .portrait

            case .landscapeLeft:
                .landscapeRight

            case .landscapeRight:
                .landscapeLeft
            }
    }

    /// Creates a new orientation value from the given UIKit interface orientation,
    /// normalizing unsupported or unspecified cases to `.portrait`.
    ///
    /// This initializer translates a `UIInterfaceOrientation` coming from UIKit
    /// (for example, from device or window orientation queries) into the internal
    /// orientation representation used by the camera module. Only the standard
    /// `.portrait`, `.landscapeLeft`, and `.landscapeRight` cases are mapped
    /// explicitly; any other orientation (such as `.portraitUpsideDown` or unknown
    /// values) is gracefully normalized to `.portrait`.
    ///
    /// - Parameter orientation: The `UIInterfaceOrientation` value to be converted
    ///   into the corresponding internal orientation.
    fileprivate init(from orientation: UIInterfaceOrientation) {
        self =
            switch orientation {
            case .portrait:
                .portrait

            case .landscapeLeft:
                .landscapeLeft

            case .landscapeRight:
                .landscapeRight

            default:
                .portrait
            }
    }
}
