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

    /// Controls whether the view is currently presented.
    @Binding var isPresented: Bool

    // MARK: - Properties

    /// A closure that produces the SwiftUI content to be presented.
    @ViewBuilder let content: () -> Content

    // MARK: - Container

    /// A container view controller used as the presentation host.
    final class ContainerController: UIViewController {
        // MARK: - Properties

        var onDidAppear: (() -> Void)?

        // MARK: - UIViewController

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onDidAppear?()
        }
    }

    // MARK: - Coordinator

    /// A helper object that coordinates updates between SwiftUI and UIKit.
    final class Coordinator {
        // MARK: - Private Properties

        private var didAppear = false
        private let parent: ScaledTransitionView
        private weak var transitionDelegate: ScaleTransitioningDelegate?

        // MARK: - Initializer

        /// Creates a coordinator for the specified parent view.
        ///
        /// - Parameter parent: The `ScaledTransitionView` instance that owns this coordinator.
        init(parent: ScaledTransitionView) {
            self.parent = parent
        }

        // MARK: - Instance Methods

        func parentDidAppear(_ controller: ContainerController) {
            didAppear = true
            update(isPresented: parent.isPresented, from: controller)
        }

        func update(isPresented: Bool, from controller: ContainerController) {
            guard didAppear else { return }

            if isPresented {
                if controller.presentedViewController is UIHostingController<Content> {
                    return
                }

                let delegate = ScaleTransitioningDelegate(startingFrame: parent.startingFrame)
                self.transitionDelegate = delegate

                let hostingController = UIHostingController(rootView: parent.content())
                hostingController.view.backgroundColor = .clear
                hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                hostingController.modalTransitionStyle = .crossDissolve
                hostingController.modalPresentationStyle = .custom
                hostingController.transitioningDelegate = self.transitionDelegate

                controller.present(hostingController, animated: true)
            } else if let presented = controller.presentedViewController {
                presented.dismiss(animated: true)
                transitionDelegate = nil
            }
        }
    }

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

    /// Sets the starting frame for the view's scale transition animation.
    ///
    /// This method configures the origin frame that the view will animate from
    /// when it appears. The frame is used by the scale transition delegate to
    /// create a smooth animation that scales from the specified frame to full screen.
    ///
    /// - Parameter frame: The CGRect that defines the starting position and size for the scale transition animation
    /// - Returns: A modified instance of the view with the starting frame set
    func startingFrame(_ frame: CGRect) -> Self {
        var view = self
        view.startingFrame = frame

        return view
    }

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> ContainerController {
        let controller = ContainerController()

        controller.onDidAppear = { [weak controller] in
            guard let controller else { return }

            context.coordinator.parentDidAppear(controller)
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: ContainerController, context: Context) {
        context.coordinator.update(isPresented: isPresented, from: uiViewController)
    }
}
