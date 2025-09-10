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

    /// The index of the clip in the media array.
    var index: Int = 0

    /// The video clip to display.
    let clip: VideoClip

    // MARK: - Private Properties

    private var playerView: PlayerView

    // MARK: - Types

    /// A UIView subclass that wraps an `AVPlayerLayer` for video playback.
    final class PlayerView: UIView {
        // MARK: - Private Properties

        private let playerLayer: AVPlayerLayer

        // MARK: - Initializers

        /// Initializes the player view with a video URL.
        ///
        /// - Parameter url: The URL of the video to play.
        init(url: URL) {
            playerLayer = AVPlayerLayer(player: AVPlayer(url: url))

            super.init(frame: .zero)

            backgroundColor = .black
            clipsToBounds = true
            layer.addSublayer(playerLayer)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Overridden methods

        override func layoutSubviews() {
            super.layoutSubviews()

            playerLayer.frame = frame
        }

        // MARK: - Instance methods

        /// Starts or resumes video playback.
        func play() {
            playerLayer.player?.play()
        }

        /// Pauses the video and resets it to the beginning.
        func stop() {
            playerLayer.player?.pause()
            playerLayer.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    // MARK: - Initializer

    /// Initializes the view controller with a video clip.
    ///
    /// - Parameter clip: The video clip to display.
    init(clip: VideoClip) {
        self.clip = clip
        playerView = PlayerView(url: clip.url)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lyfecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playerView.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        playerView.stop()
    }
}
