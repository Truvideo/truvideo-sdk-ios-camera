//
//  ARSettingsView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 24/6/24.
//

import SwiftUI

/// A custom SwiftUI view designed to display the available resolutions.
struct ARSettingsView: View {

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: ARCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack(alignment: viewModel.closeButtonAlignment) {
            ZStack(alignment: .center) {
                VStack {
                    Text("Modes")
                        .font(.title2)
                        .padding(.vertical, 16)
                    HStack {
                        makeCircularButton(
                            selected: viewModel.selectedPinObjects,
                            action: viewModel.enablePinObjects,
                            view: {
                                TruVideoImage.arrows3D
                                    .resizable()
                                    .withRenderingMode(.template, color: viewModel.selectedPinObjects ? .black : .white)
                                    .scaledToFit()
                                    .frame(minWidth: 25, minHeight: 25)
                                    .fixedSize()
                            }
                        )
                        makeCircularButton(
                            selected: viewModel.selectedRuler,
                            action: viewModel.enableRulerWithPreviouslySelectedUnit,
                            view: {
                                TruVideoImage.ruler
                                    .resizable()
                                    .withRenderingMode(.template, color: viewModel.selectedRuler ? .black : .white)
                                    .scaledToFit()
                                    .frame(minWidth: 25, minHeight: 25)
                                    .fixedSize()
                            }
                        )
                        makeCircularButton(
                            selected: viewModel.selectedVideo,
                            action: viewModel.disableModes,
                            view: {
                                TruVideoImage.video
                                    .resizable()
                                    .withRenderingMode(.template, color: viewModel.selectedVideo ? .black : .white)
                                    .scaledToFit()
                                    .frame(minWidth: 25, minHeight: 25)
                                    .fixedSize()
                            }
                        )
                    }
                    if viewModel.selectedRuler {
                        Text("Measure Units")
                            .font(.title2)
                            .padding(.vertical, 16)
                        HStack {
                            makeCircularButton(
                                selected: viewModel.selectedCentimeters,
                                action: viewModel.enableRulerWithCentimeters,
                                view: {
                                    Text("Cm")
                                        .font(.body)
                                        .foregroundStyle(viewModel.selectedCentimeters ? .black : .white)
                                }
                            )
                            makeCircularButton(
                                selected: viewModel.selectedInches,
                                action: viewModel.enableRulerWithInches,
                                view: {
                                    Text("In")
                                        .font(.body)
                                        .foregroundStyle(viewModel.selectedInches ? .black : .white)
                                }
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotationEffect(viewModel.rotationAngle)
            .animation(.spring(), value: viewModel.closeButtonAlignment)

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
            ).buttonStyle(SimpleButtonStyle())
                .padding(.horizontal, 16)
                .animation(.spring(), value: viewModel.closeButtonAlignment)
        }
    }

    private let titleHeight: CGFloat = 66.0
    private let resolutionButtonHeight: CGFloat = 46.0

    @ViewBuilder
    private func makeCircularButton(
        selected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder view: @escaping () -> some View
    ) -> some View {
        CircularButton(
            color: selected ? .iconFill : .gray.opacity(0.3),
            action: action
        ) {
            view()
        }
        .frame(minWidth: 60, minHeight: 60)
        .fixedSize()
        .transition(.opacity)
    }

}
