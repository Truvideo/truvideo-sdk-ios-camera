//
//  TimerView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 3/5/24.
//

import Combine
import SwiftUI

struct TimerViewDeprecation: View {
    var secondsRecorded: Double
    var secondsRecordedPublisher: AnyPublisher<Double, Never>
    var timerViewOffset: CGSize
    var recordStatus: RecordStatus
    let maxVideoDuration: CGFloat?

    /// The content and behavior of the view.
    var body: some View {
        PublisherListener(
            initialValue: secondsRecorded,
            publisher: secondsRecordedPublisher,
            buildWhen: { previous, current in previous != current }
        ) { secondsRecorded in

            VStack {
                Text(secondsRecorded.toHMS())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, TruVideoSpacing.sm)
                    .background(
                        Rectangle()
                            .foregroundColor(recordStatus == .recording ? .red.opacity(0.8) : .black.opacity(0.8))
                            .cornerRadius(5)
                    )

                if let maxVideoDuration, recordStatus == .recording {
                    Text(
                        calculateRemainingTime(
                            maxVideoDuration: maxVideoDuration,
                            secondsRecorded: secondsRecorded
                        )
                    )
                    .foregroundColor(.white)
                    .font(.footnote)
                }
            }
        }
        .fixedSize()
    }

    private func calculateRemainingTime(
        maxVideoDuration: Double,
        secondsRecorded: Double
    ) -> String {
        guard secondsRecorded > 0.5 else {
            return maxVideoDuration.toHMS()
        }
        return (maxVideoDuration - secondsRecorded).toHMS(roundUp: true)
    }
}

extension Double {
    /// Returns the readable Hours, Minutes and Seconds from
    /// a number of seconds recorded.
    func toHMS(roundUp: Bool = false) -> String {
        var totalSeconds = Int(self)
        if roundUp && Int(self * 1000) % 1000 != 0 {
            totalSeconds += 1
        }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
