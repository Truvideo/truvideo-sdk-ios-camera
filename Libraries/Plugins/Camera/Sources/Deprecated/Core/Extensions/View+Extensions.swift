//
//  View+Extensions.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import SwiftUI

extension View {
    /// Erases the current view to `AnyView`.
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }

    /// Sets the text style to the view.
    ///
    /// - Parameter textStyle: The text style to apply to the view.
    func textStyle(_ textStyle: TruVideoTextStyle) -> some View {
        font(
            .system(textStyle.style, design: textStyle.design)
                .weight(textStyle.weight)
        )
        .foregroundColor(textStyle.color)
    }
}
