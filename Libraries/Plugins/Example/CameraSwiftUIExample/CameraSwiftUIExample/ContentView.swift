//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI
import TruvideoSdkCamera

struct ContentView: View {
    @State private var isCameraPresented = false
    @State private var capturedMedia: [TruvideoSdkCameraMedia] = []
    @State private var alertMessage: String?
    @State private var isAlertPresented = false
    @State private var cameraOptions = CameraOptions()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                cameraControls
                    .accessibilityElement(children: .contain)

                if capturedMedia.isEmpty {
                    emptyState
                } else {
                    capturedMediaList
                }
            }
            .accessibilityElement(children: .contain)
            .padding()
            .navigationTitle("Camera SDK")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .presentTruvideoSdkCameraView(isPresented: $isCameraPresented, preset: cameraOptions.configuration) { result in
            capturedMedia = result.media
        }
        .alert("Permission Required", isPresented: $isAlertPresented, presenting: alertMessage) { _ in
            Button("OK", role: .cancel) {
                alertMessage = nil
            }
        } message: { message in
            Text(message)
        }
    }

    private var cameraControls: some View {
        VStack(spacing: 12) {
            Button("Open Camera") {
                handleOpenCameraTapped()
            }
            .buttonStyle(.borderedProminent)

            NavigationLink("Configure Camera") {
                CameraConfigurationView(options: $cameraOptions)
                    .accessibilityElement(children: .contain)
            }
            .buttonStyle(.bordered)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No media captured yet")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private var capturedMediaList: some View {
        List(capturedMedia, id: \.id) { media in
            NavigationLink {
                MediaPreview(media: media)
            } label: {
                MediaRow(media: media)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func handleOpenCameraTapped() {
        checkPermissions { granted in
            if granted {
                isCameraPresented = true
            }
        }
    }

    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        if CommandLine.arguments.contains("-CameraSwiftUIExamplePermissionsUITest") {
            completion(true)
            return
        }

        var videoGranted = false
        var audioGranted = false
        var pendingRequests = 0

        func finishIfNeeded() {
            guard pendingRequests == 0 else { return }

            let granted = videoGranted && audioGranted
            if granted {
                completion(true)
            } else {
                if !videoGranted, !audioGranted {
                    alertMessage = "Camera and microphone access are required to capture media."
                } else if !videoGranted {
                    alertMessage = "Camera access is required to preview and record media."
                } else if !audioGranted {
                    alertMessage = "Microphone access is required to capture audio during recordings."
                }

                if alertMessage != nil {
                    isAlertPresented = true
                }

                completion(false)
            }
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            videoGranted = true

        case .denied, .restricted:
            videoGranted = false

        case .notDetermined:
            pendingRequests += 1
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    videoGranted = granted
                    pendingRequests -= 1
                    finishIfNeeded()
                }
            }

        @unknown default:
            videoGranted = false
        }

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            audioGranted = true

        case .denied:
            audioGranted = false

        case .undetermined:
            pendingRequests += 1
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    audioGranted = granted
                    pendingRequests -= 1
                    finishIfNeeded()
                }
            }

        @unknown default:
            audioGranted = false
        }

        finishIfNeeded()
    }
}

#Preview {
    ContentView()
}
