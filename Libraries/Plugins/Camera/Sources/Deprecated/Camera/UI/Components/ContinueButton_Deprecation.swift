//
//  ContinueButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/5/24.
//

import SwiftUI

/// A custom SwiftUI button designed to allow users to proceed to the
/// next step or action in the camera.
struct ContinueButtonDeprecation: View {

    @State var frameSize: CGSize?

    let rotate: Bool
    let continueButtonOffset: CGSize
    let stopRecording: () -> Void

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            layer
                .background(
                    GeometryReader { proxy in
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .onAppear {
                                guard rotate else { return }
                                frameSize = .init(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                            }
                    }
                )
                .ifLet(frameSize) { view, value in
                    view.frame(width: value.width, height: value.height)
                }
        }
        .ifLet(frameSize) { view, value in
            view.frame(width: value.height, height: value.width)
        }
    }

    private var layer: some View {
        Button(action: {
            stopRecording()
        }) {
            Text("Continue")
                .foregroundStyle(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .background(Color.black.opacity(0.8))
                        .foregroundStyle(Color.gray.opacity(0.3))
                )
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(.white, lineWidth: 1)
                )
        }.buttonStyle(SimpleButtonStyle())
    }

    // MARK: Private methods

    private func makeChevronRightImage() -> some View {
        TruVideoImage.chevronRight
            .resizable()
            .withRenderingMode(.template, color: .white)
            .scaledToFit()
            .frame(width: 12, height: 12)
    }

    init(rotate: Bool = false, continueButtonOffset: CGSize, stopRecording: @escaping () -> Void) {
        self.rotate = rotate
        self.continueButtonOffset = continueButtonOffset
        self.stopRecording = stopRecording
    }
}
