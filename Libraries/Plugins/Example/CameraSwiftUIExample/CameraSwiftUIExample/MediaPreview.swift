//
// Copyright © 2025 TruVideo. All rights reserved.
//

import QuickLook
import SwiftUI
import TruvideoSdkCamera

struct MediaPreview: View {
    let media: TruvideoSdkCameraMedia

    var body: some View {
        Group {
            if media.type == .clip {
                QuickLookPreview(url: URL(fileURLWithPath: media.filePath))
                    .ignoresSafeArea()
            } else if let image = UIImage(contentsOfFile: media.filePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)

                    Text("Unable to load media.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
