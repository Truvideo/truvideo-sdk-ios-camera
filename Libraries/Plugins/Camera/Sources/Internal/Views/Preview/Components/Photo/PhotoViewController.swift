//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A view controller that displays a single photo.
///
/// Used inside `MediaPreviewPageViewController` for full-screen photo preview.
final class PhotoViewController: UIViewController {
    // MARK: - Properties

    /// The image view used to present the photo.
    let imageView = UIImageView()

    /// The index of the photo in the media array.
    var index = 0

    /// The photo to display.
    let photo: Photo

    // MARK: - Initializer

    /// Initializes the view controller with an optional image.
    ///
    /// - Parameter photo: The photo to display.
    init(photo: Photo) {
        self.photo = photo

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit

        imageView.kf.setImage(with: photo.url, options: [.memoryCacheExpiration(.expired)])
        imageView.frame = view.bounds

        view.addSubview(imageView)
    }
}
