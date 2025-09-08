//
//  View+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/11/24.
//

import Foundation
import SwiftUI

extension View {
    /// Modifies the button of the current view to represent a graphical image.
    /// The button adapts based on the selected or unselected state.
    ///
    /// - Returns: A view representing the graphical button, adapted to the selected state.
    func modifiedButton() -> some View {
        frame(minWidth: 50, minHeight: 50)
            .fixedSize()
    }

    @ViewBuilder
    func ifLet<Value, Transform: View>(
        _ optional: Value?,
        @ViewBuilder transform: (Self, Value) -> Transform
    ) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        @ViewBuilder ifTransform: (Self) -> Transform,
        @ViewBuilder elseTtransform: (Self) -> Transform
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTtransform(self)
        }
    }
}
