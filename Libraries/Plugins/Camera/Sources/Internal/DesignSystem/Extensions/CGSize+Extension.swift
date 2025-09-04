//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension CGSize {
    /// Creates a square size using the same value for both `width` and `height`.
    ///
    /// This initializer is useful when you need a `CGSize` with equal dimensions,
    /// for example to generate thumbnails, square views, or define uniform areas.
    ///
    /// - Parameter value: The value to assign to both `width` and `height`.
    init(_ value: CGFloat) {
        self.init(width: value, height: value)
    }
}
