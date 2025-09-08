//
//  MediaPreview.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/23/24.
//

import SwiftUI

enum MediaType: Hashable {
    case video(clip: TruVideoClip)
    case photo(photo: TruVideoPhoto)
}

struct GalleryItem: Hashable {
    let image: UIImage
    let type: MediaType
}

struct GalleryPreview: View {

    var isPortrait: Bool
    var galleryItems: [GalleryItem]
    var mediaScrollViewPadding: CGFloat
    var galleryHeight: CGFloat
    var rotationAngle: Angle
    var showPreview: (MediaType) -> Void
    var navigateToCameraView: () -> Void
    var setupMediaSize: (GeometryProxy) -> Void

    private func imageSize(for proxy: GeometryProxy) -> CGFloat {
        if isPortrait {
            return (proxy.size.width / 2) - mediaScrollViewPadding
        } else {
            return (proxy.size.height / 2) - mediaScrollViewPadding
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundStyle(.clear)

                    ScrollView(isPortrait ? .vertical : .horizontal, showsIndicators: false) {
                        if isPortrait {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                content: {
                                    galleryItemsView(inside: proxy)
                                }
                            )
                        } else {
                            LazyHGrid(
                                rows: [GridItem(.flexible()), GridItem(.flexible())],
                                content: {
                                    galleryItemsView(inside: proxy)
                                }
                            )
                        }
                    }
                    .if(isPortrait) { view in
                        view.frame(height: min(galleryHeight, proxy.size.height))
                    } elseTtransform: { view in
                        view.frame(width: min(galleryHeight, proxy.size.width))
                    }

                }
                .onAppear {
                    setupMediaSize(proxy)
                }
            }

            TVImageButton(image: TruVideoImage.close, style: .primary) {
                navigateToCameraView()
            }
            .padding(.trailing, 16)
            .zIndex(3)
        }
    }

    func galleryItemsView(inside proxy: GeometryProxy) -> some View {
        ForEach(galleryItems, id: \.self) { mediaContent in
            Button(action: {
                showPreview(mediaContent.type)
            }) {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: mediaContent.image)
                        .resizable()
                        .frame(
                            width: imageSize(for: proxy),
                            height: imageSize(for: proxy)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    switch mediaContent.type {
                    case .photo:
                        EmptyView()
                    case .video(let clip):
                        Text("\(clip.formattedTime)")
                            .foregroundStyle(Color.white)
                            .padding(8)
                            .background(.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(8)
                    }
                }
            }.buttonStyle(SimpleButtonStyle())
                .aspectRatio(1.0, contentMode: .fit)
                .rotationEffect(rotationAngle)
                .animation(.spring(), value: rotationAngle)
        }
    }
}

//#Preview {
//    MediaPreview()
//}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
