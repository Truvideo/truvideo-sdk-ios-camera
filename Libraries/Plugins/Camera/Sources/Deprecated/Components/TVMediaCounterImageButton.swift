//
//  TVMediaCounterImageButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 4/1/25.
//

import SwiftUI

struct TVMediaCounterImageButton: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: MediaCounterViewModel

    let action: () -> Void

    private var title: String {
        if let maxMediaCount = viewModel.maxMediaCount {
            return "\(viewModel.mediaCount)/\(maxMediaCount)"
        }
        guard viewModel.isOneModeOnly else {
            return ""
        }
        if let maxPictureCount = viewModel.maxPictureCount, maxPictureCount > 0 {
            return "\(viewModel.pictureCount)/\(maxPictureCount)"
        }
        if let maxVideoCount = viewModel.maxVideoCount, maxVideoCount > 0 {
            return "\(viewModel.videoCount)/\(maxVideoCount)"
        }
        return "\(viewModel.mediaCount)"
    }

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(uiImage: viewModel.previewImage)
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(alignment: .center) {
                    Text(title)
                        .foregroundStyle(Color.white)
                        .font(.headline.bold())
                }
        }
    }
}

struct TVMediaCounterImageButtonPreview: View {
    @ObservedObject var viewModel: MediaCounterViewModel

    init() {
        let (_, viewModel) = TVCameraFactory.shared.createPreviewCameraViewModels(for: .fixture()) { _ in }

        self.viewModel = viewModel
    }

    var body: some View {
        TVMediaCounterImageButton {

        }
        .environmentObject(viewModel)
    }
}

#Preview {
    TVMediaCounterImageButtonPreview()
}
