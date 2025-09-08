//
//  RecordButton.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import Combine
import SwiftUI

/// A circular button with some functionality to enable/disable
/// dependeing of the current orientation.
struct RecordButtonDeprecation: View {
    /// Whether the user is long pressing the button
    @State private var isOnLongPressing = false

    var recordStatus: RecordStatus
    var recordStatusPublisher: AnyPublisher<RecordStatus, Never>
    var allowRecordingVideos: Bool
    var record: () -> Void
    var pause: () -> Void
    var takePhoto: () -> Void

    /// The radius of the circule inside the button.
    private var innerCircleWidth: CGFloat {
        recordStatus == .recording ? 45 : 60
    }

    /// The radius of the record/pause button
    func getCornerRadius(for recordStatus: Published<RecordStatus>.Publisher.Output) -> CGFloat {
        recordStatus == .recording ? 8 : innerCircleWidth / 2
    }

    /// The content and behavior of the view.
    var body: some View {
        PublisherListener(
            initialValue: recordStatus,
            publisher: recordStatusPublisher,
            buildWhen: { previous, current in previous != current }
        ) { recordStatus in

            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 70, height: 70)

                RoundedRectangle(cornerRadius: getCornerRadius(for: recordStatus))
                    .fill(recordStatus == RecordStatus.recording ? .red : .white)
                    .frame(width: innerCircleWidth, height: innerCircleWidth)
            }
            .scaleEffect(x: isOnLongPressing ? 0.8 : 1, y: isOnLongPressing ? 0.8 : 1)
            .animation(.spring(response: 1, dampingFraction: 0.5, blendDuration: 1), value: isOnLongPressing)
            .onLongPressGesture(minimumDuration: 0.3, perform: onLongPress)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded(onDragEnded)
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded(onTapEnded)
            )
        }
    }

    // MARK: Private methods

    private func onDragEnded(_ value: DragGesture.Value) {
        let dragAllowed = recordStatus == .recording

        guard isOnLongPressing && dragAllowed else { return }

        guard allowRecordingVideos else {
            takePhoto()
            return
        }

        record()

        withAnimation {
            isOnLongPressing.toggle()
        }
    }

    private func onLongPress() {
        guard recordStatus == .recording else { return }

        withAnimation {
            isOnLongPressing.toggle()
        }
    }

    private func onTapEnded(_ value: TapGesture.Value) {
        guard allowRecordingVideos else {
            takePhoto()
            return
        }

        guard recordStatus == .recording else {
            record()
            return
        }

        pause()
    }
}
