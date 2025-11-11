//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import TruvideoSdkCamera

struct MediaRow: View {
    let media: TruvideoSdkCameraMedia

    var body: some View {
        HStack {
            Image(systemName: media.type == .clip ? "video" : "photo")
                .frame(width: 32, height: 32)
                .foregroundStyle(media.type == .clip ? .blue : .green)

            VStack(alignment: .leading, spacing: 4) {
                Text(media.filePath.components(separatedBy: "/").last ?? media.filePath)
                    .lineLimit(1)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var description: String {
        if media.type == .clip {
            let duration = String(format: "%.1fs", media.duration / 1000)
            return "Video – Duration: \(duration)"
        }
        return "Photo"
    }
}
