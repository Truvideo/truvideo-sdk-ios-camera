//
//  CameraOverlay.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 5/20/25.
//

import SwiftUI

struct CameraOverlay: View {
    let overlayPage: CameraOverlayPage

    @EnvironmentObject var viewModel: TVCameraViewModel

    var body: some View {
        overlay()
    }

    @ViewBuilder private func overlay() -> some View {
        switch overlayPage {
        case .resolutionPicker:
            TVResolutionPicker()

        case .galleryPreview:
            GalleryPreview(
                isPortrait: viewModel.layoutOrientation.isPortrait,
                galleryItems: viewModel.galleryItems,
                mediaScrollViewPadding: viewModel.mediaScrollViewPadding,
                galleryHeight: viewModel.gallerySize,
                rotationAngle: viewModel.rotationAngleValue,
                showPreview: viewModel.showPreview,
                navigateToCameraView: viewModel.navigateToCameraView,
                setupMediaSize: viewModel.setupMediaSize
            )

        case .close:
            CloseView(
                isPortrait: viewModel.layoutOrientation.isPortrait,
                closeButtonAlignment: .topLeading,
                rotationAngle: viewModel.rotationAngleValue,
                navigateToCameraView: viewModel.navigateToCameraView,
                closeCameraAndDeleteMedia: {
                    viewModel.closeCameraAndDeleteMedia()
                }
            )

        case .videoPreview(let clip):
            VideoPreviewDeprecation(
                clip: clip,
                rotationAngle: viewModel.rotationAngleValue,
                returnToGalleryPreview: viewModel.returnToGalleryPreview,
                deleteClip: viewModel.deleteClip
            )

        case .photoPreview(let photo):
            PhotoPreview(
                photo: photo,
                rotationAngle: viewModel.rotationAngleValue,
                returnToGalleryPreview: viewModel.returnToGalleryPreview,
                deletePhoto: viewModel.deletePhoto
            )
        case .loading:
            LoadingView()
        }
    }
}

#Preview {
    CameraOverlay(overlayPage: .close)
}
