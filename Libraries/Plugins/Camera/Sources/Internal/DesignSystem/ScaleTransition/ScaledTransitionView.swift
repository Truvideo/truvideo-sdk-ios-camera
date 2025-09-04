//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import SwiftUI

/// A UIViewControllerRepresentable that provides custom scale transition animations.
///
/// This struct creates a bridge between SwiftUI and UIKit to enable custom
/// presentation animations with scale transitions. It manages the presentation
/// lifecycle of a SwiftUI view using a UIHostingController and custom
/// transitioning delegate to create smooth scale animations from a starting
/// frame to full screen.
///
/// The view uses a binding to control presentation state and provides a fluent
/// API for configuring the starting frame. It handles both presentation and
/// dismissal automatically based on the binding state, ensuring proper cleanup
/// and memory management.
struct ScaledTransitionView<Content: View>: UIViewControllerRepresentable {
    // MARK: - Private Properties

    private var startingFrame = CGRect.zero

    // MARK: - Binding Properties

    /// Controls whether the gallery is currently presented.
    @Binding var isPresented: Bool

    // MARK: - Properties

    @ViewBuilder let content: @MainActor () -> Content

    // MARK: - Initializer

    /// Creates a new instance with a binding to control presentation state and content builder.
    ///
    /// This initializer sets up the presentation controller with a binding that allows
    /// the parent view to control whether the content is presented or dismissed. The
    /// content builder closure provides the view content that will be displayed when
    /// the presentation is active, allowing for flexible and reusable presentation
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the content is currently presented
    ///   - content: A closure that returns the view content to be presented
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content
    }

    // MARK: - Instance methods

    /// Sets the starting frame for the gallery's scale transition animation.
    ///
    /// This method configures the origin frame that the gallery will animate from
    /// when it appears. The frame is used by the scale transition delegate to
    /// create a smooth animation that scales from the specified frame to full screen.
    ///
    /// - Parameter frame: The CGRect that defines the starting position and size for the scale transition animation
    /// - Returns: A modified instance of the gallery view with the starting frame set
    func startingFrame(_ frame: CGRect) -> Self {
        var galleryView = self
        galleryView.startingFrame = frame

        return galleryView
    }

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> ScaleTransitioningDelegate {
        ScaleTransitioningDelegate()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if uiViewController.presentedViewController is UIHostingController<Content> {
                return
            }

            let hostingController = UIHostingController(rootView: content())
            hostingController.view.backgroundColor = .red
            hostingController.view.bounds = uiViewController.view.bounds

            context.coordinator.startingFrame = startingFrame
            hostingController.modalPresentationStyle = .custom
            hostingController.transitioningDelegate = context.coordinator

            DispatchQueue.main.async {
                if uiViewController.view.window != nil, uiViewController.view.window != nil {
                    uiViewController.present(hostingController, animated: true)
                }
            }
        } else if let presentedViewController = uiViewController.presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
}
