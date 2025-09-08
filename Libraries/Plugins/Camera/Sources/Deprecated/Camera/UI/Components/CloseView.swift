//
//  CloseView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/23/24.
//

import SwiftUI

struct CloseView: View {

    var isPortrait: Bool
    var closeButtonAlignment: Alignment
    var rotationAngle: Angle
    var navigateToCameraView: () -> Void
    var closeCameraAndDeleteMedia: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.clear)

            VStack {
                Text("EXIT")
                    .font(.title2.bold())
                Text("Would you like to discard all videos and images?")
                    .font(.body)
                    .multilineTextAlignment(.center)
                discardButton
                cancelButton
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .rotationEffect(rotationAngle)
            .animation(.spring(), value: rotationAngle)
        }
        .overlay(alignment: .topLeading) {
            TVImageButton(image: TruVideoImage.close, style: .primary) {
                navigateToCameraView()
            }
            .padding(.trailing, 16)
        }
    }

    var cancelButton: some View {
        Button(
            action: {
                navigateToCameraView()
            },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.gray)
                        .frame(height: 32)
                        .padding(.horizontal, 32)
                    Text("CANCEL")
                        .font(.body.bold())
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }

    var discardButton: some View {
        Button(
            action: {
                closeCameraAndDeleteMedia()
            },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.red)
                        .frame(height: 32)
                        .padding(.horizontal, 32)
                    Text("DISCARD")
                        .font(.body.bold())
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}
