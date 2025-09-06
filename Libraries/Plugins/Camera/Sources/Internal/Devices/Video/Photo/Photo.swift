//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit

final class Photo {
    let createdAt: TimeInterval

    let format: FileFormat

    let orientation: UIDeviceOrientation

    let url: URL

    // MARK: - Lazy Properties

    lazy var image: UIImage? = {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return UIImage(data: data)
    }()

    // MARK: - Initializer

    init(
        url: URL,
        format: FileFormat,
        orientation: UIDeviceOrientation,
        createdAt: TimeInterval = Date().timeIntervalSince1970
    ) {

        self.createdAt = createdAt
        self.format = format
        self.orientation = orientation
        self.url = url
    }
}

extension Photo: Equatable {

    // MARK: - Hashable

    /// Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.url == rhs.url
    }
}
