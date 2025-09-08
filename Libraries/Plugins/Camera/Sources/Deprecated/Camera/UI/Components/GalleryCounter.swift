//
//  GalleryCounter.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 15/5/24.
//

import SwiftUI

/// A user interface that shows the current number of videos and pictures
/// that the user has taken.
struct GalleryCounter: View {
    var countClips: Int
    var photos: [TruVideoPhoto]

    /// The content and behavior of the view.
    var body: some View {
        container {
            HStack(spacing: TruVideoSpacing.xxs) {
                TruVideoImage.play
                    .resizable()
                    .withRenderingMode(.template, color: .white)
                    .scaledToFit()
                    .frame(width: 15, height: 10)

                Text("\(countClips)")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }

            HStack(spacing: TruVideoSpacing.xxs) {
                TruVideoImage.image
                    .resizable()
                    .withRenderingMode(.template, color: .white)
                    .scaledToFit()
                    .frame(width: 15, height: 10)

                Text("\(photos.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
        }
        .opacity(countClips == 0 && photos.isEmpty ? 0 : 1)
        .padding(.bottom, TruVideoSpacing.xlg)
    }

    @ViewBuilder
    private func container<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        HStack(spacing: TruVideoSpacing.xs) {
            content()
                .offset(x: 12, y: 12)
        }
    }
}
