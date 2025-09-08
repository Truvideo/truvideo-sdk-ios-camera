//
//  ToastModifier.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/16/24.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    let message: String
    let alignment: Alignment
    let rotationAngle: Angle
    let duration: Double = 2.0
    let offset: CGSize

    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            content
            if isShowing {
                Text(message)
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .padding()
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    .rotationEffect(rotationAngle)
                    .multilineTextAlignment(.center)
                    .offset(offset)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                // Hide toast
                                isShowing = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        alignment: Alignment,
        rotationAngle: Angle,
        offset: CGSize
    ) -> some View {
        self.modifier(
            ToastModifier(
                message: message,
                alignment: alignment,
                rotationAngle: rotationAngle,
                offset: offset,
                isShowing: isShowing
            )
        )
    }
}

struct ToastPortrait_Preview: PreviewProvider {
    static var previews: some View {
        GeometryReader { _ in
            Color.green
        }
        .toast(
            isShowing: .constant(true),
            message: "Maximum video duration reached!",
            alignment: .bottom,
            rotationAngle: .degrees(0),
            offset: .zero
        )
    }
}

struct ToastLandscapeLeft_Preview: PreviewProvider {
    static var previews: some View {
        GeometryReader { _ in
            Color.green
        }
        .toast(
            isShowing: .constant(true),
            message: "Maximum video",
            alignment: .leading,
            rotationAngle: .degrees(90),
            offset: .zero
        )
    }
}

struct ToastLandscapeRight_Preview: PreviewProvider {
    static var previews: some View {
        GeometryReader { _ in
            Color.green
        }
        .toast(
            isShowing: .constant(true),
            message: "Maximum video duration reached!",
            alignment: .trailing,
            rotationAngle: .degrees(270),
            offset: .zero
        )
    }
}

struct ToastPortraitReverse_Preview: PreviewProvider {
    static var previews: some View {
        GeometryReader { _ in
            Color.green
        }
        .toast(
            isShowing: .constant(true),
            message: "Maximum video duration reached! Maximum video duration reached!",
            alignment: .top,
            rotationAngle: .degrees(180),
            offset: .zero
        )
    }
}
