//
//  VideoPreview.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import AVKit
import SwiftUI

/// Shows the camera for recording videos
struct VideoPreviewDeprecation: View {
    let clip: TruVideoClip
    let rotationAngle: Angle
    let returnToGalleryPreview: () -> Void
    let deleteClip: (TruVideoClip) -> Void

    @State var videoPlayerSize = CGSize.zero

    private func getVideoAspectRatio() -> Double {
        let url = clip.url
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("No video track found: \(url.absoluteString)")
            return 828.0 / 1792.0
        }

        // Get the natural size and transform
        let naturalSize = track.naturalSize
        let transform = track.preferredTransform

        // Calculate the actual size considering the transform
        let videoSize = transform.a == 0 ? CGSize(width: naturalSize.height, height: naturalSize.width) : naturalSize

        // Calculate and return the aspect ratio (width / height)
        return Double(videoSize.width / videoSize.height)
    }

    private func calculateVideoPlayerSize(for proxy: GeometryProxy) -> CGSize {
        let videoAspectRatio = getVideoAspectRatio()
        let screenAspectRatio = proxy.size.width / proxy.size.height

        let videoHeight: CGFloat
        let videoWidth: CGFloat

        if rotationAngle.degrees == 0 || rotationAngle.degrees == 180 {
            if videoAspectRatio < screenAspectRatio {
                videoHeight = proxy.size.height
                videoWidth = videoAspectRatio * videoHeight
            } else {
                videoWidth = proxy.size.width
                videoHeight = videoWidth / videoAspectRatio
            }
        } else {
            let videoInvertedASpectRatio = 1 / videoAspectRatio

            if videoInvertedASpectRatio > screenAspectRatio {
                videoHeight = proxy.size.width
                videoWidth = videoAspectRatio * videoHeight
            } else {
                videoWidth = proxy.size.height
                videoHeight = videoWidth / videoAspectRatio
            }
        }

        return .init(width: videoWidth, height: videoHeight)
    }

    var body: some View {
        if rotationAngle.degrees == 0 || rotationAngle.degrees == 180 {
            layer
        } else {
            layer
        }
    }

    var layer: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .foregroundStyle(.black)
                    .onAppear {
                        videoPlayerSize = calculateVideoPlayerSize(for: proxy)
                    }

                VideoPlayerViewDeprecation(url: clip.url)
                    .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
                    .rotationEffect(rotationAngle)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .overlay(alignment: .topLeading) {
            HStack {
                TVImageButton(image: TruVideoImage.trash, style: .primary) {
                    deleteClip(clip)
                }
                .rotationEffect(rotationAngle)

                TVImageButton(image: TruVideoImage.close, style: .primary) {
                    returnToGalleryPreview()
                }
                .rotationEffect(rotationAngle)
            }
            .padding(.trailing, 16)
            .zIndex(3)
        }
    }
}

struct VideoPlayerViewDeprecation: View {
    private var url: URL
    @State var player: AVPlayer

    init(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
    }

    var body: some View {
        AVKit.VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
    }
}
