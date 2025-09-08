//
//  TVResolutionPicker.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 4/2/25.
//

import SwiftUI

struct TVResolutionPicker: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                        height: viewModel.layoutOrientation.isPortrait
                            ? getScrollViewHeight(maxHeight: geometry.size.height)
                            : getScrollViewHeight(maxHeight: geometry.size.width)
                    )
                    .rotationEffect(viewModel.rotationAngleValue)
                    .animation(.spring(), value: viewModel.rotationAngleValue)
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
    }

    private let titleHeight: CGFloat = 66.0
    private var resolutionButtonHeight: CGFloat {
        viewModel.preset.isHighResolutionPhotoEnabled ? 80.0 : 60.0
    }

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
                viewModel.changeResolution(to: resolution)
                viewModel.navigateToCameraView()
            },
            label: {
                ZStack(alignment: .center) {
                    VStack {
                        Text("\(resolution.width)x\(resolution.height)")
                            .font(.body)
                            .foregroundStyle(viewModel.selectedResolution == resolution ? .black : .white)

                        if viewModel.preset.isHighResolutionPhotoEnabled, resolution.supportsHighResolutionPhotos {
                            Text("HRP: \(resolution.highResolutionPhotoWidth)x\(resolution.highResolutionPhotoHeight)")
                                .font(.body)
                                .foregroundStyle(viewModel.selectedResolution == resolution ? .black : .white)
                        }
                    }
                    .frame(height: viewModel.preset.isHighResolutionPhotoEnabled ? 48 : 32)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(
                                viewModel.selectedResolution == resolution ? Color.iconFill : .gray.opacity(0.3)
                            )
                    )
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}

struct TVResolutionPickerPreview: View {

    @ObservedObject var viewModel: TVCameraViewModel

    init() {
        let (viewModel, _) = TVCameraFactory.shared.createPreviewCameraViewModels(for: .fixture()) { _ in }

        self.viewModel = viewModel
    }

    var body: some View {
        TVResolutionPicker()
            .environmentObject(viewModel)
    }
}

#Preview {
    TVResolutionPickerPreview()
}
