//
//  TVMediaCounterButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVMediaCounterButton: View {
    enum ButtonStyle {
        case primary
        case secondary

        var foregroundColor: Color {
            switch self {
            case .primary:
                return Color(red: 33 / 255, green: 33 / 255, blue: 33 / 255)
            case .secondary:
                return .white
            }
        }

        var backgroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .clear
            }
        }
    }

    let title: String

    let style: TVMediaCounterButton.ButtonStyle

    let action: () -> Void

    init(title: String, style: TVMediaCounterButton.ButtonStyle, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .foregroundStyle(style.foregroundColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(style.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
    }
}

struct TVSegmentedButtonPreview: View {
    var body: some View {
        VStack {
            Spacer()

            HStack {
                TVMediaCounterButton(title: "Photos 3/5", style: .primary) {}

                TVMediaCounterButton(title: "Videos 3/5", style: .secondary) {}
            }
            .padding(2)
            .background(Color.black.opacity(0.4))
            .padding(.horizontal, 32)

            HStack {
                TVMediaCounterButton(title: "Photos 3/5", style: .secondary) {}

                TVMediaCounterButton(title: "Videos 3/5", style: .primary) {}
            }
            .padding(2)
            .background(Color.black.opacity(0.4))
            .padding(.horizontal, 32)

            Spacer()
        }
        .background(Color.yellow)
    }
}

#Preview {
    TVSegmentedButtonPreview()
}
