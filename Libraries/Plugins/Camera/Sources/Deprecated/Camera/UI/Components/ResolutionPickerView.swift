//
//  ImageQuality.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI

/// A custom SwiftUI view designed to display the available resolutions.
struct ResolutionPickerView: View {

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: CameraViewModelDeprecation

    /// The content and behavior of the view.
    var body: some View {
        if viewModel.isPortrait {
            layer
        } else {
            layer
        }
    }

    /// The content and behavior of the view.
    var layer: some View {
        ZStack(alignment: viewModel.closeButtonAlignment) {
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundStyle(.clear)
                    ScrollView(showsIndicators: false) {
                        Text("RESOLUTIONS")
                            .font(.title2)
                            .padding(.vertical, 16)

                        ForEach(
                            viewModel.getResolutions(),
                            id: \.self
                        ) { resolution in
                            makeResolutionButton(for: resolution)
                        }
                        .padding(.horizontal, 64)
                        .padding(.bottom, 8)
                    }
                    .frame(
                        height: viewModel.isPortrait
                            ? getScrollViewHeight(maxHeight: geometry.size.height)
                            : getScrollViewHeight(maxHeight: geometry.size.width)
                    )
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
                }
            }

            Button(
                action: {
                    viewModel.navigateToCameraView()
                },
                label: {
                    ZStack {
                        Circle()
                            .frame(width: 40)
                            .foregroundStyle(.gray.opacity(0.3))
                        TruVideoImage.close
                            .resizable()
                            .withRenderingMode(
                                .template,
                                color: .white
                            )
                            .scaledToFit()
                            .frame(minWidth: 17, minHeight: 17)
                            .fixedSize()
                    }
                }
            )
            .padding(.horizontal, 16)
        }
        .animation(.spring(), value: viewModel.closeButtonAlignment)
    }

    private let titleHeight: CGFloat = 66.0
    private let resolutionButtonHeight: CGFloat = 46.0

    private func getScrollViewHeight(maxHeight: CGFloat) -> CGFloat {
        min(
            maxHeight,
            titleHeight + (resolutionButtonHeight * CGFloat(viewModel.getResolutions().count))
        )
    }

    // MARK: Private methods
    private func makeResolutionButton(for resolution: TruvideoSdkCameraResolutionFormat) -> some View {
        Button(
            action: {
                viewModel.setSelectedResolution(resolution)
                viewModel.navigateToCameraView()
            },
            label: {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 32)
                        .foregroundStyle(
                            viewModel.selectedResolution == resolution ? Color.iconFill : .gray.opacity(0.3)
                        )
                    Text("\(resolution.width)x\(resolution.height)")
                        .font(.body)
                        .foregroundStyle(viewModel.selectedResolution == resolution ? .black : .white)
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}

//#Preview {
//    ResolutionPickerView()
//}
