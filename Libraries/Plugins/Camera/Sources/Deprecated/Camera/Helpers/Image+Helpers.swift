//
//  Image+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/11/24.
//

import Foundation
import SwiftUI

extension Image {
    /// Modifies the icon of the current view to represent a graphical image.
    /// The icon adapts based on the selected or unselected state.
    ///
    /// - Returns: A view representing the graphical icon, adapted to the selected state.
    func modifiedIcon(width: CGFloat = 25, height: CGFloat = 25) -> some View {
        resizable()
            .withRenderingMode(.template, color: .white)
            .scaledToFit()
            .frame(width: width, height: height)
    }
}
