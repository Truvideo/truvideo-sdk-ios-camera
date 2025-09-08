//
//  ImagePreview.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/25/24.
//

import SwiftUI

struct PhotoPreview: View {

    let photo: TruVideoPhoto
    let rotationAngle: Angle
    let returnToGalleryPreview: () -> Void
    let deletePhoto: (TruVideoPhoto) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.clear)

            if let image = photo.captureImage.rotate(radians: rotationAngle.radians) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .animation(.spring(), value: rotationAngle)
            } else {
                Text("Could not preview photo.")
            }
        }
        .overlay(alignment: .topLeading) {
            HStack {
                TVImageButton(image: TruVideoImage.trash, style: .primary) {
                    deletePhoto(photo)
                }
                .rotationEffect(rotationAngle)

                TVImageButton(image: TruVideoImage.close, style: .primary) {
                    returnToGalleryPreview()
                }
                .rotationEffect(rotationAngle)
            }
            .padding(.trailing, 16)
        }
    }
}
