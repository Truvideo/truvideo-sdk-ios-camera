//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A reusable collection view cell that displays an image thumbnail
/// and optionally a duration label (e.g., for video clips).
final class ImageCellView: UICollectionViewCell {
    // MARK: - Properties

    /// The reuse identifier for this cell.
    static let reuseId = "ImageCell"

    /// The main image view used to display thumbnails or photos.
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Private Properties

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    // MARK: - Initializer

    /// Initializes the cell with the given frame and sets up its subviews.
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(durationLabel)

        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        durationLabel.isHidden = true
    }

    // MARK: - Instance Methods

    /// Configures the cell with the provided media, theme, and parent view controller.
    ///
    /// - Parameters:
    ///   - media: The media object to display, either a photo or a clip.
    ///   - theme: The theme used for styling (corner radius, fonts, colors).
    ///   - parent: The parent view controller hosting this cell.
    func configure(with media: Media, theme: Theme, parent: UIViewController) {
        contentView.layer.cornerRadius = theme.radiusTheme.xs
        contentView.layer.masksToBounds = true

        switch media {
        case let .clip(clip):
            imageView.isHidden = false
            imageView.image = clip.thumbnail ?? UIImage()

            durationLabel.textColor = UIColor(theme.colorScheme.onSurface)
            durationLabel.backgroundColor = .clear
            durationLabel.isHidden = false
            durationLabel.text = clip.duration.toHMS()
            durationLabel.font = UIFont(
                name: theme.textTheme.callout.fontName,
                size: theme.textTheme.callout.fontSize
            )

        case let .photo(photo):
            imageView.image = photo.image
        }
    }
}
