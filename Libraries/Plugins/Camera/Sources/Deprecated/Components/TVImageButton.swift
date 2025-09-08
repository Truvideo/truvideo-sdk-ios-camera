//
//  TVImageButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

/// A circular black background button with a sligthly opacity.
struct TVImageButton: View {
    enum ButtonStyle {
        case primary
        case secondary

        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return Color(red: 33 / 255, green: 33 / 255, blue: 33 / 255)
            }
        }

        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color(red: 33 / 255, green: 33 / 255, blue: 33 / 255)
            case .secondary:
                return .white
            }
        }
    }

    /// The view to use for the button.
    let image: Image

    /// The  color for the background.
    let style: TVImageButton.ButtonStyle

    /// The callback action for the button.
    let action: () -> Void

    /// The content and behavior of the view.
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(style.backgroundColor)

                image
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(style.foregroundColor)
                    .frame(maxWidth: 24, maxHeight: 24)
            }
            .frame(width: 48, height: 48)
        }
    }

    // MARK: Initalizers

    /// Creates a new instance of the `CircularButton`
    ///
    /// - Parameters:
    ///    - image: The  image to present.
    ///    - style: The  style for the button background.
    ///    - action: The callback action for the button
    init(
        image: Image,
        style: TVImageButton.ButtonStyle,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.style = style
        self.action = action
    }
}

struct TVImageButtonPreview: View {
    var body: some View {
        VStack {
            HStack {
                TVImageButton(image: TruVideoImage.close, style: .primary) {}

                TVImageButton(image: TruVideoImage.close, style: .secondary) {}
            }

            HStack {
                TVImageButton(image: TruVideoImage.flash, style: .primary) {}

                TVImageButton(image: TruVideoImage.flash, style: .secondary) {}
            }

            HStack {
                TVImageButton(image: TruVideoImage.fullHD, style: .primary) {}

                TVImageButton(image: TruVideoImage.fullHD, style: .secondary) {}
            }

            HStack {
                TVImageButton(image: TruVideoImage.chevronRight, style: .primary) {}

                TVImageButton(image: TruVideoImage.chevronRight, style: .secondary) {}
            }

            HStack {
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {}

                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .secondary) {}
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    TVImageButtonPreview()
}
