//
// Created by TruVideo on 21/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

@objc extension UIViewController {
    /// Presents the AR camera view over the full screen.
    ///
    /// The camera view is presented **modally in full screen**, and once the session ends, the result is passed back to the caller.
    ///
    /// - Parameters:
    ///    - preset: A `TruvideoSdkARCameraConfiguration` object containing the AR camera configuration.
    ///    - onComplete: A callback function that receives a `TruvideoSdkCameraResult` containing captured media.
    @objc public func presentTruvideoSdkARCameraView(
        preset: TruvideoSdkARCameraConfiguration = .init(flashMode: .off, mode: .videoAndPicture(), orientation: nil),
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) {
        let preset: TruvideoSdkCameraConfiguration = .init(
            flashMode: preset.flashMode,
            lensFacing: .back,
            mode: preset.mode,
            outputPath: ""
        )
        let onCompleteDecorator: (TruvideoSdkCameraResult) -> Void = { [weak self] result in
            self?.presentedViewController?.dismiss(animated: true) {
                onComplete(result)
            }
        }
        let viewController = TruvideoSdkCameraViewController(
            viewBuilder: {
                TruvideoSdkARCameraView(preset: preset, onComplete: onCompleteDecorator)
            }
        )
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

/// Support for `UIKit` compatibility
class TruvideoSdkCameraViewController<V: View>: UIViewController {

    typealias ViewBuilder = () -> V
    /// Preset configuration
    private var viewBuilder: ViewBuilder?
    private var child: UIViewController?

    convenience init(
        viewBuilder: @escaping ViewBuilder
    ) {
        self.init()
        self.viewBuilder = viewBuilder
        TruvideoSdkOrientationManager.shared.appIsActive = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let newSize = CGRect(origin: .zero, size: size)
        coordinator.animate(
            alongsideTransition: { context in
                UIView.animate(
                    withDuration: context.transitionDuration,
                    animations: {
                        self.child?.view.frame = newSize
                    }
                )
            },
            completion: { context in }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildren()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDeviceOrientation.currentAppOrientation().interfaceOrientationMask
    }

    private func addChildren() {
        guard let viewBuilder else { return }
        let cameraView = UIHostingController(rootView: viewBuilder())
        cameraView.modalPresentationStyle = .fullScreen
        addChild(cameraView)
        cameraView.view.frame = view.frame

        view.addSubview(cameraView.view)

        cameraView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.view.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        cameraView.didMove(toParent: self)
        child = cameraView
    }
}
