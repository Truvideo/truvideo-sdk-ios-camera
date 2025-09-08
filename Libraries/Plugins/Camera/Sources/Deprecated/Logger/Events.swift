//
//  LogEvent.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/24/24.
//

import AVFoundation
import Foundation

enum Event: String {
    case authValidate = "event_camera_auth_validate"
    case videoPermission = "event_video_permission"
    case microphonePermission = "microphone_permission_denied"
    case sessionStarted = "session_started"
    case sessionStopped = "session_stopped"
    case startRecordingFailed = "start_recording_failed"
    case recordingStopped = "recording_stopped"
    case recordingStarted = "recording_started"
    case notificationMediaServicesReset = "notification_media_services_reset"
    case notificationSessionRuntimeError = "notification_session_runtime_error"
    case notificationSessionWasInterrupted = "notification_session_was_interrupted"
    case notificationSessionWasInterruptedEnded = "notification_session_interruption_ended"
    case notificationAppWillResignActive = "notification_app_will_resign_active"
    case notificationAppBecameActive = "notification_app_became_active"
    case torchNotSupported = "torch_not_supported"
    case torchToggleFailed = "torch_toggle_failed"
    case sessionConfigurationBegin = "session_configuration_begin"
    case sessionConfigurationCommit = "session_configuration_commit"
    case recordingFailed = "recording_failed"
    case photoTaken = "photo_taken"
    case cameraFlipped = "camera_flipped"
    case torchToggled = "torch_toggled"
    case resolutionChanged = "resolution_changed"
    case sessionCleaned = "session_cleaned"
    case recoveringSession = "recovering_session"
    case cameraResolutionFailed = "camera_resolution_failed"
    case focusFailed = "focus_failed"

    case getCameraInformation = "event_camera_get_camera_information"
    case openCamera = "event_camera_open"
    case takePicture = "event_camera_take_picture"
    case stopRecording = "event_camera_recording_stop"
    case startRecording = "event_camera_recording_start"
    case openMediaPanel = "event_camera_panel_media_open"
    case openMediaDetailPanel = "event_camera_panel_media_detail_open"
    case continueButtonPressed = "event_camera_button_continue_pressed"
    case closeButtonPressed = "event_camera_button_close_pressed"
    case openDiscardPanel = "event_camera_panel_discard_open"
    case backButtonPressed = "event_camera_button_back_pressed"  // es necesario?
    case openResolutionPanel = "event_camera_panel_resolution_open"
    case flash = "event_camera_flash"
    case pauseRecording = "event_camera_recording_pause"
    case resumeRecording = "event_camera_recording_resume"
    case flipCamera = "event_camera_flip"
    case changeResolution = "event_camera_resolution_change"
    case deleteMedia = "event_camera_media_delete"
    case discard = "event_camera_discard"
    case zoom = "event_camera_zoom"
    case focus = "event_camera_focus"
    case maxVideoDurationReached = "event_camera_recording_duration_limit"
    case media = "event_camera_media"
    case initialConfiguration = "event_initial_configuration"
    case configureVideo = "event_configure_video"
    case configureAudio = "event_configure_audio"

    var name: String {
        self.rawValue
    }
}

enum EventMessage {
    case notAuthenticated
    case getCameraInformation
    case cameraOpenWithConfiguration(preset: TruvideoSdkCameraConfiguration)
    case takePicture
    case videoLimitReached
    case pictureLimitReached
    case startRecording
    case stopRecording
    case mediaLimitReached

    case openMediaPanel
    case openDetailMediaPanel(media: MediaType)
    case continueButtonPressed(result: TruvideoSdkCameraResult)
    case closeButtonPressed
    case openDiscardPanel
    case backButtonPressed
    case openResolutionPanel
    case toggleFlashTo(currentFlashMode: TorchStatus)
    case pauseRecording

    case resumeRecording
    case flipCameraTo(lensFacing: AVCaptureDevice.Position)
    case changeResolution(cameraFormat: TruvideoSdkCameraResolutionFormat)
    case deleteMedia(media: MediaType)
    case discardAllMedia
    case zoom(value: CGFloat)
    case focusLocked
    case focusRequested
    case newFlashMode(flasModeName: TorchStatus)
    case camera
    case videoDurationLimitReached(limit: CGFloat)
    case newMedia(media: MediaType)

    case videoPermissionDenied
    case microphonePermissionDenied
    case sessionStarted
    case sessionStopped
    case startRecordingFailed
    case recordingStarted
    case recordingStopped
    case notificationMediaServicesReset
    case notificationSessionRuntimeError
    case notificationSessionWasInterrupted
    case notificationSessionWasInterruptedEnded
    case notificationAppWillResignActive
    case notificationAppBecameActive
    case torchNotSupported
    case torchToggleFailed(error: Error)
    case sessionConfigurationBegin
    case sessionConfigurationCommit
    case recordingFailed
    case photoTaken
    case cameraFlipped
    case torchToggled
    case resolutionChanged
    case sessionCleaned
    case recoveringSession

    case initialConfigurationFailed(error: Error)
    case toggleFlashFailed(error: Error)
    case deleteMediaFailed(error: Error)
    case takePhotoFailed
    case stopRecordingFailed(error: Error)

    case configureVideoFailed(error: Error)
    case configureAudioFailed(error: Error)
    case configureResolutionFailed(error: Error)
    case configureZoomFailed(error: Error)
    case focusFailed(error: Error)

    var message: String {
        switch self {
        case .notAuthenticated:
            "validate authentication failed: SDK not authenticated"

        case .getCameraInformation:
            "Getting camera information"

        case .cameraOpenWithConfiguration(let preset):
            "The camera screen has opened. Configuration: \(preset)"

        case .takePicture:
            "Take picture"

        case .videoLimitReached:
            "Video limit reached"

        case .pictureLimitReached:
            "Picture limit reached"

        case .startRecording:
            "Start recording"

        case .stopRecording:
            "Stop recording"

        case .mediaLimitReached:
            "Media limit reached"

        case .openMediaPanel:
            "Open panel media"

        case .openDetailMediaPanel(let media):
            "Open panel media detail. Media: \(media)"

        case .continueButtonPressed(let result):
            "Button continue pressed. Result: \(result)"

        case .closeButtonPressed:
            "Button close pressed"

        case .openDiscardPanel:
            "Open panel discard"

        case .backButtonPressed:
            "Button back pressed"

        case .openResolutionPanel:
            "Open resolution panel"

        case .toggleFlashTo(let currentFlashMode):
            "Toggle flash. Current: \(currentFlashMode)"

        case .pauseRecording:
            "Pause recording"

        case .resumeRecording:
            "Resume recording"

        case .flipCameraTo(let lensFacing):
            "Flip camera. Current: \(lensFacing)"

        case .changeResolution(let cameraFormat):
            "Change resolution. \(cameraFormat.width)x\(cameraFormat.height)"

        case .deleteMedia(let media):
            "Delete media: \(media)"

        case .discardAllMedia:
            "Discard all media"

        case .zoom(let value):
            "New value: \(value)"

        case .focusLocked:
            "Focus locked"

        case .focusRequested:
            "Focus requested"

        case .newFlashMode(let flasModeName):
            "New flash mode: \(flasModeName)"

        case .camera:
            "Camera: $json"

        case .videoDurationLimitReached(let limit):
            "Video duration limit reached. \(limit)"

        case .videoPermissionDenied:
            "User denied camera permission"

        case .microphonePermissionDenied:
            "User denied microphone permission"

        case .sessionStarted:
            "The session has started"

        case .sessionStopped:
            "The session has been stopped"

        case .startRecordingFailed:
            "Failed to start recording"

        case .recordingStarted:
            "Recording has been started"

        case .recordingStopped:
            "Recording has been stopped"

        case .notificationMediaServicesReset:
            "Session media service reset notification received"

        case .notificationSessionRuntimeError:
            "Session run time error notification received"

        case .notificationSessionWasInterrupted:
            "Session interruption notification received"

        case .notificationSessionWasInterruptedEnded:
            "Session interruption notification ended"

        case .notificationAppWillResignActive:
            "App will resign active notification received"

        case .notificationAppBecameActive:
            "App became active notification received"

        case .torchNotSupported:
            "Torch not supported"

        case .torchToggleFailed(let error):
            "Torch toggle failed: \(error)"

        case .sessionConfigurationBegin:
            "Session configuration has begun"

        case .sessionConfigurationCommit:
            "Session configuration has been committed"

        case .recordingFailed:
            "Saving recording failed"

        case .photoTaken:
            "Photo has been taken"

        case .cameraFlipped:
            "Camera has been flipped"

        case .torchToggled:
            "Torch has been toggled"

        case .resolutionChanged:
            "Resoltion has been changed"

        case .sessionCleaned:
            "Session has been cleaned"

        case .recoveringSession:
            "Recovering session"

        case .newMedia(let media):
            "New media: \(media)"

        case .initialConfigurationFailed(let error):
            "Initial configuration failed. \(error)"

        case .toggleFlashFailed(let error):
            "Toggle flash failed. \(error)"

        case .deleteMediaFailed(let error):
            "Delete media failed \(error)"

        case .takePhotoFailed:
            "Take photo failed."

        case .stopRecordingFailed(let error):
            "Stop recording failed. \(error)"

        case .configureVideoFailed(let error):
            "Configure video failed. \(error)"

        case .configureAudioFailed(let error):
            "Configure audio failed. \(error)"

        case .configureResolutionFailed(let error):
            "Configure resolution failed. \(error)"

        case .configureZoomFailed(let error):
            "Configure zoom value failed. \(error)"

        case .focusFailed(let error):
            "Focus failed. \(error)"
        }
    }
}
