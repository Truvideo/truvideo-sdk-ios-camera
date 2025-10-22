//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import SwiftUI
import UIKit

/// A view controller that displays a single video clip.
///
/// Used inside `MediaPreviewPageViewController` for full-screen video preview.
final class ClipViewController: UIViewController {
    // MARK: - Properties

    /// The video clip to display.
    let clip: VideoClip

    /// The image view used to present the video.
    let imageView = UIImageView()

    /// The index of the clip in the media array.
    var index = 0

    // MARK: - Private Properties

    /// The player for playback control.
    private let player: AVPlayer

    // MARK: - Initializer

    /// Initializes the view controller with a video clip.
    ///
    /// - Parameter clip: The video to display.
    init(clip: VideoClip) {
        self.clip = clip
        self.player = AVPlayer(url: clip.url)
        imageView.kf.setImage(with: clip.thumbnailURL)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lyfecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoPlayerView = VideoPlayerView(player: player)
        let hostingController = UIHostingController(rootView: videoPlayerView)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingController)

        view.backgroundColor = .black
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        player.seek(to: .zero)
    }
}

/// A  view that displays a video using an `AVPlayer`.
struct VideoPlayerView: View {
    // MARK: - Properties

    let player: AVPlayer

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Body

    var body: some View {
        VideoPlayer(player: player)
            .padding(.top, UIDevice.current.isPad ? theme.spacingTheme.x(10) : theme.spacingTheme.xxxl)
            .background {
                Color.black
                    .ignoresSafeArea()
            }
    }
}
