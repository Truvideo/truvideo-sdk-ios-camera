//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import SwiftUI
import UIKit

extension View {
    /// Presents a full-screen camera interface for media capture.
    ///
    /// This function creates and presents a camera view that allows users to capture
    /// pictures and videos according to the specified configuration. The camera
    /// interface is displayed as a full-screen modal that covers the entire screen
    /// and provides a native camera experience with capture controls.
    ///
    /// The camera configuration can be customized to control capture limits,
    /// video duration, media types, and other camera behavior settings.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the camera view is displayed
    ///   - preset: Configuration settings for the camera behavior (default: default configuration)
    ///   - onComplete: Closure called when the camera session completes with captured media
    /// - Returns: A SwiftUI view that presents the camera interface when activated
    public func presentTruvideoSdkCameraView(
        isPresented: Binding<Bool>,
        preset: TruvideoSdkCameraConfiguration = TruvideoSdkCameraConfiguration(),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> some View {
        modifier(CameraPresenterViewModifier(isPresented: isPresented, configuration: preset, onComplete: onComplete))
    }
}

private struct CameraPresenterViewModifier: ViewModifier {
    // MARK: - Binding Properties

    @Binding var isPresented: Bool

    // MARK: - Properties

    /// Configuration settings for the camera behavior.
    let configuration: TruvideoSdkCameraConfiguration

    /// Closure called when the camera session completes with captured media
    let onComplete: (TruvideoSdkCameraResult) -> Void

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            guard isPresented else {
                CameraHostingController.dismiss()
                return
            }

            Task { @MainActor in
                await withDependencyValues { dependencyValues in
                    dependencyValues.orientationMonitor = PhysicalOrientationMonitor()

                    CameraHostingController.present(configuration: configuration, onComplete: onComplete) {
                        self.isPresented = false
                    }
                }
            }
        }
    }
}

extension CameraHostingController {
    // MARK: - Static methods

    /// Dismisses the currently presented `CameraHostingController`, if any.
    ///
    /// This method looks up the top-most view controller in the current application
    /// window hierarchy using `UIApplication.shared.topMostViewController`. If the
    /// top-most controller is an instance of `CameraHostingController`, it triggers
    /// a standard UIKit dismissal (`dismiss(animated:completion:)`).
    ///
    /// If the top-most view controller is **not** a `CameraHostingController`, the
    /// method performs no action and the `completion` closure is **not** called.
    ///
    /// - Parameter completion: A closure to be executed after the camera hosting
    ///   controller has been dismissed. This closure is only invoked when a
    ///   `CameraHostingController` is actually found and dismissed.
    fileprivate static func dismiss(completion: @escaping (() -> Void) = {}) {
        let topMostViewController = UIApplication.shared.topMostViewController

        if topMostViewController is CameraHostingController {
            topMostViewController?.dismiss(animated: true, completion: completion)
        }
    }

    /// Presents the TruVideo camera as a full-screen `CameraHostingController`
    /// from the current top-most view controller.
    ///
    /// This method creates a new instance of `CameraHostingController` configured
    /// with the provided `TruvideoSdkCameraConfiguration` and callback closures,
    /// and presents it modally in full-screen mode from the application's
    /// `topMostViewController`.
    ///
    /// - Parameters:
    ///   - configuration: The configuration used to initialize the TruVideo camera.
    ///     Defaults to a new `TruvideoSdkCameraConfiguration` instance.
    ///   - onComplete: A closure invoked when the camera flow finishes with a
    ///     `TruvideoSdkCameraResult` (for example, after capturing or confirming
    ///     media). This closure is typically used to propagate the result back to
    ///     the caller.
    ///   - onDismiss: A closure invoked when the camera screen is dismissed,
    ///     regardless of whether it completed successfully or was cancelled.
    ///     This is useful for keeping external presentation state (such as a
    ///     `Binding<Bool> isPresented` in SwiftUI) in sync with the actual UI.
    fileprivate static func present(
        configuration: TruvideoSdkCameraConfiguration = TruvideoSdkCameraConfiguration(),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let cameraHostingController = CameraHostingController(
            configuration: configuration,
            onComplete: onComplete,
            onDismiss: onDismiss
        )

        cameraHostingController.modalPresentationStyle = .fullScreen

        UIApplication.shared.topMostViewController?.present(cameraHostingController, animated: true)
    }
}

extension UIApplication {
    /// Returns the top-most view controller in the receiver's presentation hierarchy.
    ///
    /// This computed property walks through the current view controller hierarchy to
    /// determine which view controller is currently at the top and visible to the user.
    fileprivate var topMostViewController: UIViewController? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}
