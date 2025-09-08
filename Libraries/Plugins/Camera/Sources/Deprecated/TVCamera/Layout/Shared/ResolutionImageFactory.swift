//
//  ResolutionImageFactory.swift
//  TruvideoSdkCamera
//
//  Created by Paul Alvarez on 11/06/25.
//

import SwiftUI

struct ResolutionImageFactory {
    static func image(for type: ResolutionImageType) -> Image {
        let size = CGSize(width: 52, height: 52)
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiImage = renderer.image { ctx in
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: type.fontSize),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph,
            ]
            let textRect = CGRect(
                x: 0,
                y: size.height * type.verticalOffset,
                width: size.width,
                height: size.height * type.textHeight
            )
            type.label.draw(in: textRect, withAttributes: attrs)
        }
        return Image(uiImage: uiImage)
    }
}

enum ResolutionImageType {
    case sd, hd, fullHD, uhd

    var label: String {
        switch self {
        case .sd: return "SD"
        case .hd: return "HD"
        case .fullHD: return "FHD"
        case .uhd: return "UHD"
        }
    }

    var fontSize: CGFloat {
        label.count == 2 ? 32 : 24
    }

    var verticalOffset: CGFloat {
        label.count == 2 ? 0.18 : 0.25
    }

    var textHeight: CGFloat {
        label.count == 2 ? 0.64 : 0.5
    }
}

struct ResolutionImageFactoryPreview: View {
    var body: some View {
        VStack(spacing: 8) {
            ResolutionImageFactory.image(for: .sd)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
            ResolutionImageFactory.image(for: .hd)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
            ResolutionImageFactory.image(for: .fullHD)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
            ResolutionImageFactory.image(for: .uhd)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
        }
        .padding()
        .background(Color.gray)
    }
}

#Preview {
    ResolutionImageFactoryPreview()
}
