//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import TruvideoSdkCamera

struct CameraConfigurationView: View {
    @Binding var options: CameraOptions

    var body: some View {
        Form {
            Section("Lens") {
                Picker("Lens", selection: $options.lens) {
                    Text("Back").tag(TruvideoSdkCameraLensFacing.back)
                    Text("Front").tag(TruvideoSdkCameraLensFacing.front)
                }
                .pickerStyle(.segmented)
            }

            Section("Flash") {
                Picker("Flash", selection: $options.flash) {
                    Text("Off").tag(TruvideoSdkCameraFlashMode.off)
                    Text("On").tag(TruvideoSdkCameraFlashMode.on)
                }
                .pickerStyle(.segmented)
            }

            Section("Image Format") {
                Picker("Format", selection: $options.imageFormat) {
                    Text("JPEG").tag(TruvideoSdkCameraImageFormat.jpeg)
                    Text("PNG").tag(TruvideoSdkCameraImageFormat.png)
                }
                .pickerStyle(.segmented)
            }

            Section("Capture Mode") {
                Picker("Mode", selection: $options.mediaMode) {
                    Text("Photo Only").tag(CameraOptions.MediaMode.photoOnly)
                    Text("Video Only").tag(CameraOptions.MediaMode.videoOnly)
                    Text("Photo & Video").tag(CameraOptions.MediaMode.videoAndPicture)
                }

                Picker("Limit", selection: $options.mediaLimit) {
                    Text("Single").tag(CameraOptions.MediaLimit.single)
                    Text("Limited").tag(CameraOptions.MediaLimit.limited)
                    Text("Unlimited").tag(CameraOptions.MediaLimit.unlimited)
                }

                if options.mediaMode != .photoOnly {
                    HStack {
                        Text("Video Duration (s)")
                        Spacer()
                        TextField("Seconds", value: $options.videoDuration, formatter: NumberFormatter.integer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                if options.mediaLimit == .limited {
                    if options.mediaMode != .videoOnly {
                        Stepper(value: $options.pictureLimit, in: 1...Int.max) {
                            Text("Max Photos: \(options.pictureLimit)")
                        }
                    }

                    if options.mediaMode != .photoOnly {
                        Stepper(value: $options.videoLimit, in: 1...Int.max) {
                            Text("Max Videos: \(options.videoLimit)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Camera Configuration")
    }
}

private extension NumberFormatter {
    static var integer: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
}

