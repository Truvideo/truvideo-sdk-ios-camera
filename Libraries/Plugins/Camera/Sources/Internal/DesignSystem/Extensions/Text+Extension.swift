//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension Text {
    /// Applies the text style to the `Text`.
    ///
    /// - Parameter style: The text style to apply to the view
    @MainActor
    public func style(_ style: TextStyle) -> Text {
        let text = font(.custom(style.fontName, size: style.fontSize))
            .foregroundColor(style.color)
            .kerning(style.kerning)

        return switch style.decoration {
        case .strikethrough:
            text.strikethrough()

        case .underline:
            text.underline()

        default:
            text
        }
    }
}
