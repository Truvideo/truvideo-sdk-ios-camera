//
//  MediaCounter.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/17/24.
//

import SwiftUI

struct MediaCounter: View {
    @ObservedObject var viewModel: MediaCounterViewModel

    let rotate: Bool
    var textSize: Font = .body
    let onAction: () -> Void

    var body: some View {
        if viewModel.triggerUpdate {
            mediaCounterContent
        } else {
            mediaCounterContent
        }
    }

    var mediaCounterContent: some View {
        ZStack {
            layer
                .background(
                    GeometryReader { proxy in
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .onAppear {
                                guard rotate else { return }
                                viewModel.frameSize = .init(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                            }
                    }
                )
                .ifLet(viewModel.frameSize) { view, value in
                    view.frame(width: value.width, height: value.height)
                }
        }
        .ifLet(viewModel.frameSize) { view, value in
            view.frame(width: value.height, height: value.width)
        }
    }

    private var layer: some View {
        Button {
            onAction()
        } label: {
            HStack(spacing: 8) {
                mediaCounter()
                videoCounter()
                pictureCounter()
            }
            .if(viewModel.hasContent) {
                $0.foregroundStyle(Color.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.gray.opacity(0.3))
                    .background(.black.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
            }
        }.buttonStyle(SimpleButtonStyle())
    }

    @ViewBuilder
    private func mediaCounter() -> some View {
        Group {
            if let maxMediaCount = viewModel.maxMediaCount {
                Counter(
                    mode: .withMax(
                        count: viewModel.mediaCount,
                        max: maxMediaCount
                    ),
                    systemImageName: nil,
                    textSize: textSize
                )
            }
        }
    }

    @ViewBuilder
    private func videoCounter() -> some View {
        if let maxVideoCount = viewModel.maxVideoCount {
            Counter(
                mode: .withMax(
                    count: viewModel.videoCount,
                    max: maxVideoCount
                ),
                systemImageName: "video",
                textSize: textSize
            )
        } else {
            Counter(
                mode: .withoutMax(count: viewModel.videoCount),
                systemImageName: "video",
                textSize: textSize
            )
        }
    }

    @ViewBuilder
    private func pictureCounter() -> some View {
        if let maxPictureCount = viewModel.maxPictureCount {
            Counter(
                mode: .withMax(
                    count: viewModel.pictureCount,
                    max: maxPictureCount
                ),
                systemImageName: "photo",
                textSize: textSize
            )
        } else {
            Counter(
                mode: .withoutMax(count: viewModel.pictureCount),
                systemImageName: "photo",
                textSize: textSize
            )
        }
    }

    init(
        rotate: Bool = false,
        viewModel: MediaCounterViewModel,
        textSize: Font = .body,
        onAction: @escaping () -> Void
    ) {
        self.rotate = rotate
        self.textSize = textSize
        self.viewModel = viewModel
        self.onAction = onAction
    }
}

extension MediaCounterViewModel {
    fileprivate convenience init(
        videoCount: Int,
        pictureCount: Int,
        mode: TruvideoSdkCameraMediaMode
    ) {
        self.init(mode: mode)
        self.videoCount = videoCount
        self.pictureCount = pictureCount
    }

    fileprivate convenience init(
        mediaCount: Int,
        videoCount: Int,
        pictureCount: Int,
        mode: TruvideoSdkCameraMediaMode
    ) {
        self.init(mode: mode)
        self.mediaCount = mediaCount
        self.videoCount = videoCount
        self.pictureCount = pictureCount
    }
}
