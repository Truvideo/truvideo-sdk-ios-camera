//
//  TVRecordButton.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVRecordButton: View {
    let segmendtedOption: TVMediaCounterPickerButton.SegmentedOption
    let isRecording: Bool

    let action: () -> Void

    init(
        segmendtedOption: TVMediaCounterPickerButton.SegmentedOption,
        isRecording: Bool,
        action: @escaping () -> Void
    ) {
        self.segmendtedOption = segmendtedOption
        self.isRecording = isRecording
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .overlay {
                    switch segmendtedOption {
                    case .photos:
                        photosOverlay()
                    case .videos:
                        videosOverlay()
                    }
                }
        }
    }

    @ViewBuilder
    private func photosOverlay() -> some View {
        Circle()
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .overlay(
                Circle().stroke(Color.black, lineWidth: 1)
            )
    }

    @ViewBuilder
    private func videosOverlay() -> some View {
        Circle()
            .foregroundStyle(isRecording ? .black : .red)
            .frame(width: 56, height: 56)
            .overlay {
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.red)
                } else {
                    Circle().stroke(Color.black, lineWidth: 1)
                }
            }
    }
}

struct TVRecordButtonPreview: View {
    var body: some View {
        VStack {
            TVRecordButton(segmendtedOption: .photos, isRecording: false) {}

            TVRecordButton(segmendtedOption: .videos, isRecording: false) {}

            TVRecordButton(segmendtedOption: .videos, isRecording: true) {}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    TVRecordButtonPreview()
}
