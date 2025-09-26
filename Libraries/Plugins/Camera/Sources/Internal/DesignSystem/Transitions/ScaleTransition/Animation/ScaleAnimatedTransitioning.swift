//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A custom animator that handles "scale in" and "fade out" transitions
/// for presenting and dismissing a view controller.
///
/// When presenting, the view controller scales up from a given `originRect`
/// to its final frame. When dismissing, the view controller fades out.
final class ScaleAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Private Properties

    private let duration: TimeInterval = 0.38
    private let isPresenting: Bool
    private let originRect: CGRect

    // MARK: - Initializer

    /// Creates a scale animator for either presenting or dismissing a view controller.
    ///
    /// - Parameters:
    ///   - isPresenting: A Boolean indicating if the animation is for presenting (`true`) or dismissing (`false`).
    ///   - originRect: The starting rectangle for the "scale in" effect when presenting.
    init(isPresenting: Bool, originRect: CGRect) {
        self.isPresenting = isPresenting
        self.originRect = originRect
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard isPresenting else {
            dismissAnimation(using: context)
            return
        }

        presentAnimation(using: context)
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    // MARK: - Private methods

    private func dismissAnimation(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView

        guard let fromVC = context.viewController(forKey: .from) else {
            context.completeTransition(false)
            return
        }

        let convertedOrigin = container.convert(originRect, from: nil)
        let originCenter = CGPoint(x: convertedOrigin.midX, y: convertedOrigin.midY)

        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                fromVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                fromVC.view.layer.cornerRadius = 6
            }

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                fromVC.view.layer.cornerRadius = 20
                fromVC.view.center = originCenter
                fromVC.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                fromVC.view.alpha = 0.8
            }
        } completion: { finished in
            fromVC.view.removeFromSuperview()
            context.completeTransition(finished)
        }
    }

    private func presentAnimation(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView

        guard let toVC = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let finalFrame = context.finalFrame(for: toVC)
        let convertedOrigin = container.convert(originRect, from: nil)
        let originCenter = CGPoint(x: convertedOrigin.midX, y: convertedOrigin.midY)
        let finalCenter = CGPoint(x: finalFrame.midX, y: finalFrame.midY)

        toVC.view.frame = finalFrame
        toVC.view.center = originCenter
        toVC.view.clipsToBounds = true
        toVC.view.layer.cornerRadius = 6
        toVC.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        toVC.view.alpha = 0.8

        container.addSubview(toVC.view)

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7) {
                toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                toVC.view.center = finalCenter
                toVC.view.alpha = 1.0
                toVC.view.layer.cornerRadius = 3
            }

            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                toVC.view.transform = .identity
                toVC.view.layer.cornerRadius = 0
            }
        } completion: { finished in
            context.completeTransition(finished)
        }
    }
}

/// A custom transitioning delegate that provides scale-based animations
/// when presenting and dismissing a view controller.
///
/// This delegate acts as a bridge between UIKit's transition system
/// (`UIViewControllerTransitioningDelegate`) and a custom animator (`ScaleAnimator`).
final class ScaleTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    // MARK: - Properties

    /// The frame from which the presented view controller should originate
    /// during the scale-in transition, and to which it should shrink back during the scale-out transition.
    var startingFrame = CGRect.zero

    /// Creates a scale transitioning delegate with a specified starting frame.
    ///
    /// - Parameter startingFrame:
    ///   The initial frame from which the presented view controller should expand
    ///   during presentation, and to which it should contract during dismissal.
    init(startingFrame: CGRect) {
        self.startingFrame = startingFrame
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        ScaleAnimatedTransitioning(isPresenting: true, originRect: startingFrame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ScaleAnimatedTransitioning(isPresenting: false, originRect: startingFrame)
    }
}
