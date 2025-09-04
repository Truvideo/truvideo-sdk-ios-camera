//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension Button where Label == Text {
    // MARK: - Initializer

    /// Creates a button that displays a custom label.
    ///
    /// - Parameters:
    ///   - label: A text that describes the purpose of the button's `action`.
    ///   - alignment: The alignment of the button's child.
    ///   - action: The action to perform when the user triggers the button.
    public init(_ label: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(label)
        }
    }
}
