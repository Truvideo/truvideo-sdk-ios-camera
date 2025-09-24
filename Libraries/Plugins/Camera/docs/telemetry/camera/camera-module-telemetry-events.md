# 📊 Camera Module Telemetry Events

This document defines the **Telemetry events** used to track interactions, states, and system notifications in the Camera module.  
It covers **per-screen events** (photo, video, system) as well as **global events** that apply across the camera flow.  

---

## 🌍 Global Events
Global events are tracked independently and apply to all camera flows.  

See [Global Screen View & Breadcrumb Events](./screen-view.md) for details.  

---

## 📸 Capture Photo Events
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **photo_capture_started** | ![Info](https://img.shields.io/badge/Info-green) | User initiated a photo capture. | **device**, **flashMode** |
| **photo_capture_succeeded** | ![Info](https://img.shields.io/badge/Info-green) | Photo successfully captured. | **device**, **resolution**, **mediaId** |
| **photo_capture_failed** | ![Error](https://img.shields.io/badge/Error-red) | Photo capture failed. | **device**, **error** |

---

## 🎥 Recording Video Events
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **video_recording_started** | ![Info](https://img.shields.io/badge/Info-green) | User started video recording. | **device**, **resolution**, **isTorchEnabled** |
| **video_recording_paused** | ![Info](https://img.shields.io/badge/Info-green) | User paused video recording. | **device**, **duration** |
| **video_recording_resumed** | ![Info](https://img.shields.io/badge/Info-green) | User resumed video recording. | **device**, **duration** |
| **video_recording_stopped** | ![Info](https://img.shields.io/badge/Info-green) | User stopped video recording. | **device**, **duration**, **mediaId** |
| **video_recording_failed** | ![Error](https://img.shields.io/badge/Error-red) | Video recording failed. | **device**, **error** |
| **video_recording_max_duration_reached** | ![Warning](https://img.shields.io/badge/Warning-yellow) | Maximum recording duration reached. | **device**, **duration**, **mediaId** |

---

## 🔒 Permissions & Authorization Events
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **authorization_requested** | ![Info](https://img.shields.io/badge/Info-green) | User prompted for camera and/or microphone permissions. | **devices** |
| **authorization_granted** | ![Info](https://img.shields.io/badge/Info-green) | Both camera and microphone access granted. | **devices** |
| **authorization_camera_denied** | ![Error](https://img.shields.io/badge/Error-red) | Camera permission denied. | **device**, **status** |
| **authorization_microphone_denied** | ![Error](https://img.shields.io/badge/Error-red) | Microphone permission denied. | **device**, **status** |

---

## 🛠️ Camera Interaction Events
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **camera_switched** | ![Info](https://img.shields.io/badge/Info-green) | User switched between front/back cameras. | **previousDevice**, **newDevice** |
| **camera_torch_toggled** | ![Info](https://img.shields.io/badge/Info-green) | Torch (flashlight) turned on/off. | **device**, **isTorchEnabled** |
| **camera_zoom_changed** | ![Info](https://img.shields.io/badge/Info-green) | Zoom factor changed. | **device**, **zoomFactor** |
| **camera_focus_changed** | ![Info](https://img.shields.io/badge/Info-green) | User tapped to change focus. | **device**, **focusPoint** |

---

## ✅ Validation & Completion Events
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **media_validation_succeeded** | ![Info](https://img.shields.io/badge/Info-green) | Media collection passed validation. | **mediaCount**, **state** |
| **media_validation_failed** | ![Error](https://img.shields.io/badge/Error-red) | Media collection failed validation. | **mediaCount**, **state** |
| **operation_completed** | ![Info](https://img.shields.io/badge/Info-green) | Camera operation finished successfully. | **mediaCount**, **result** |
| **camera_dismissed_with_unsaved_media** | ![Warning](https://img.shields.io/badge/Warning-yellow) | User dismissed camera while unsaved media still present. | **mediaCount**, **mediaTypes** |

---

## ⚙️ Camera System Notifications
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **camera_received_services_were_reset** | ![Info](https://img.shields.io/badge/Info-green) | Camera module received a system reset notification. | **statusCode**, **isRecording**, **device**, **resolution** |
| **camera_recovering_from_reset** | ![Info](https://img.shields.io/badge/Info-green) | Camera is attempting to recover from system reset. | **statusCode**, **isRecording** |
| **camera_recovered_from_reset** | ![Info](https://img.shields.io/badge/Info-green) | Camera successfully recovered from system reset. | **statusCode**, **isRecording** |
| **camera_failed_to_recover_from_reset** | ![Error](https://img.shields.io/badge/Error-red) | Camera failed to recover after system reset. | **statusCode**, **error**, **isRecording** |
| **camera_audio_route_change_received** | ![Info](https://img.shields.io/badge/Info-green) | Camera module received an audio route change notification. | **route**, **reason**, **isRecording** |
| **camera_audio_route_change_failed** | ![Error](https://img.shields.io/badge/Error-red) | Camera module failed to reconfigure audio after route change. | **error**, **route**, **reason**, **isRecording** |
| **camera_runtime_error_received** | ![Error](https://img.shields.io/badge/Error-red) | Camera capture session received a runtime error notification. | **statusCode**, **error**, **device**, **isRecording** |
| **camera_session_interrupted** | ![Info](https://img.shields.io/badge/Info-green) | Camera capture session was interrupted by the system. | **reason**, **isRecording** |

---

## 📖 Metadata Glossary

Below is a reference of all metadata fields captured across Camera Module telemetry events:

- **aspectRatio** → Current aspect ratio of the preview (e.g., `9:16`, `16:9`).  
- **device** → Active capture device:  
  - `"front_camera"` → front-facing camera  
  - `"back_camera"` → rear-facing camera  
  - `"microphone"` → active audio input device  
  - `"unknown"` → could not be determined  
- **devices** → List of devices involved in permission prompt (e.g., `["camera","microphone"]`).  
- **duration** → Length of video recording in seconds.  
- **error** → Human-readable error message string.  
- **flashMode** → Flash setting during capture (`on`, `off`, `auto`).  
- **focusPoint** → Normalized coordinates (0–1) where user tapped to focus.  
- **isRecording** → Boolean indicating if a recording was active.  
- **isTorchEnabled** → Boolean indicating torch state (on/off).  
- **mediaCount** → Number of media items currently captured.  
- **mediaId** → Identifier for a specific media item (photo/video).  
- **mediaTypes** → Types of media present (e.g., `["photo"]`, `["video","photo"]`).  
- **newDevice** → Device after switching (front/back).  
- **previousDevice** → Device before switching (front/back).  
- **reason** → Reason for interruption or route change (e.g., `oldDeviceUnavailable`, `systemPressure`).  
- **resolution** → Current capture preset (`720p`, `1080p`, `4k`).  
- **result** → Outcome of operation (e.g., `success`, `cancelled`).  
- **route** → Audio route transition (e.g., `"speaker → headphones"`).  
- **screenName** → Name of the screen/view being tracked.  
- **state** → Validation or recording state (`initialized`, `running`, `paused`, `finished`, `invalid`).  
- **status** → Authorization status (`authorized`, `denied`, `restricted`).  
- **statusCode** → Numeric AVFoundation error/status code (e.g., `-11819`).  
- **zoomFactor** → Current zoom factor applied to the preview.  

---

📌 This structure ensures:  
- **Global events** stay centralized.  
- **Per-screen events** are self-contained.  
- **Glossary** avoids repetition and makes telemetry fields clear across the repo.  
