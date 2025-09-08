//
//  TVMediaCounterPickerButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVMediaCounterPickerButton: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: MediaCounterViewModel

    enum SegmentedOption {
        case photos
        case videos
    }

    var selectedOption: Binding<SegmentedOption>

    init(selectedOption: Binding<SegmentedOption>) {
        self.selectedOption = selectedOption
    }

    private var photosText: String {
        if let maxPictureCount = viewModel.maxPictureCount {
            "Photos \(viewModel.pictureCount)/\(maxPictureCount)"
        } else if viewModel.pictureCount > 0, viewModel.maxMediaCount == nil {
            "Photos \(viewModel.pictureCount)"
        } else {
            "Photos"
        }
    }

    private var videosText: String {
        if let maxVideoCount = viewModel.maxVideoCount {
            "Videos \(viewModel.videoCount)/\(maxVideoCount)"
        } else if viewModel.videoCount > 0, viewModel.maxMediaCount == nil {
            "Videos \(viewModel.videoCount)"
        } else {
            "Videos"
        }
    }

    private var photosStyle: TVMediaCounterButton.ButtonStyle {
        switch selectedOption.wrappedValue {
        case .photos:
            return .primary
        case .videos:
            return .secondary
        }
    }

    private var videosStyle: TVMediaCounterButton.ButtonStyle {
        switch selectedOption.wrappedValue {
        case .photos:
            return .secondary
        case .videos:
            return .primary
        }
    }

    var body: some View {
        HStack {
            TVMediaCounterButton(title: photosText, style: photosStyle) {
                selectedOption.wrappedValue = .photos
            }

            TVMediaCounterButton(title: videosText, style: videosStyle) {
                selectedOption.wrappedValue = .videos
            }
        }
        .padding(2)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
        .padding(.horizontal, 32)
    }
}

struct TVMediaCounterPickerButtonPreview: View {
    @ObservedObject var viewModel: MediaCounterViewModel

    init() {
        let (_, viewModel) = TVCameraFactory.shared.createPreviewCameraViewModels(for: .fixture()) { _ in }

        self.viewModel = viewModel
    }

    var body: some View {
        TVMediaCounterPickerButton(selectedOption: .constant(.photos))
            .environmentObject(viewModel)
    }
}

#Preview {
    TVMediaCounterPickerButtonPreview()
}
