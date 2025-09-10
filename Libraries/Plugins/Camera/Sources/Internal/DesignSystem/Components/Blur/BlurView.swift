//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A SwiftUI view that wraps a `UIVisualEffectView` to provide blur effects.
///
/// Use `BlurView` to apply native iOS blur effects to your SwiftUI views. This view
/// bridges UIKit's `UIVisualEffectView` into SwiftUI, allowing you to easily add
/// blur backgrounds, overlays, or visual effects to your interface.
///
/// Example usage:
/// ```swift
/// ZStack {
///     Image("background")
///         .resizable()
///         .aspectRatio(contentMode: .fill)
///
///     BlurView(style: .systemMaterial)
///         .opacity(0.8)
///
///     Text("Content over blur")
///         .foregroundColor(.primary)
/// }
/// ```
///
/// This struct creates a blur effect view that can be used as a background, overlay,
/// or standalone visual element with various blur styles available through `UIBlurEffect.Style`.
struct BlurView: UIViewRepresentable {
    // MARK: - Properties

    /// The style of the blur effect to be applied.
    ///
    /// This property determines the visual appearance of the blur effect, including
    /// its intensity, color tinting, and overall aesthetic.
    let style: UIBlurEffect.Style

    // MARK: - UIViewRepresentable

    /// Creates the underlying `UIVisualEffectView` with the specified blur style.
    ///
    /// This method is called when SwiftUI needs to create the UIKit view that will
    /// be displayed. It creates a `UIVisualEffectView` with the blur effect style
    /// specified in the `style` property.
    ///
    /// - Parameter context: The context in which the view is being created.
    /// - Returns: A `UIVisualEffectView` configured with the specified blur effect.
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    /// Updates the underlying UIKit view when SwiftUI state changes.
    ///
    /// This method is called whenever SwiftUI needs to update the view due to
    /// state changes. For `BlurView`, no updates are needed since the blur style
    /// is immutable after creation.
    ///
    /// - Parameters:
    ///   - uiView: The UIKit view to update.
    ///   - context: The context containing information about the update.
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
