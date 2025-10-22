# 📊 Camera Module Telemetry Events

This document defines the **Telemetry events** used to track interactions, states, and system notifications in the Camera module.  
It covers **per-screen events** (photo, video, system) as well as **global events** that apply across the camera flow.  

---

## 🌍 Global Events
Global events are tracked independently and apply to all camera flows.  

See [Global Screen View & Breadcrumb Events](./screen-view.md) for details.  

---

## 📸 Capture Photo Events

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **photo_capture** | ![Info](https://img.shields.io/badge/Info-green) | Photo capture started | **devicePosition**, **flashMode**, **resolution** |
| **photo_capture** | ![Info](https://img.shields.io/badge/Info-green) | Photo captured successfully | **devicePosition**, **flashMode**, **resolution** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `photo_capture_failed` | ![Error](https://img.shields.io/badge/Error-red) | Photo capture failed | **devicePosition**, **flashMode**, **resolution** |

---

## 🎥 Recording Video Events

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **video_recording** | ![Info](https://img.shields.io/badge/Info-green) | Video recording started | **devicePosition**, **resolution**, **isTorchAvailable**, **isTorchEnabled**, **codec**, **aspectRatio**, **zoomFactor**, **stabilizationMode**, **maxDuration**, **isAudioAvailable** |
| **video_recording** | ![Info](https://img.shields.io/badge/Info-green) | Video recording paused | **devicePosition**, **duration**, **clipCount**, **zoomFactor** |
| **video_recording** | ![Info](https://img.shields.io/badge/Info-green) | Video recording resumed | **devicePosition**, **duration**, **clipCount**, **zoomFactor** |
| **video_recording** | ![Info](https://img.shields.io/badge/Info-green) | Video recording stopped | **devicePosition**, **duration**, **clipCount**, **zoomFactor** |
| **video_recording** | ![Warning](https://img.shields.io/badge/Warning-yellow) | Maximum recording duration reached | **devicePosition**, **duration**, **maxDuration**, **clipCount** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `video_recording_failed` | ![Error](https://img.shields.io/badge/Error-red) | Video recording failed | **devicePosition**, **resolution**, **duration**, **processorState**, **isAudioAvailable** |
| `camera_torch_error_during_recording` | ![Error](https://img.shields.io/badge/Error-red) | Torch error while recording | **hasTorch**, **isTorchAvailable**, **flashMode** |

---

## 🔒 Permissions & Authorization Events

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **authorization** | ![Info](https://img.shields.io/badge/Info-green) | Authorization requested | **devices** |
| **authorization** | ![Info](https://img.shields.io/badge/Info-green) | Authorization granted | **devices** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `camera_permission_denied` | ![Error](https://img.shields.io/badge/Error-red) | Camera permission denied | **device**, **status** |
| `microphone_permission_denied` | ![Error](https://img.shields.io/badge/Error-red) | Microphone permission denied | **device**, **status** |

---

## 🛠️ Camera Interaction Events

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Camera switched | **previousDevicePosition**, **newDevicePosition** |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Torch toggled | **devicePosition**, **isTorchEnabled** |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Zoom magnification started | **devicePosition**, **magnificationValue**, **lastZoomFactor** |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Zoom changed | **devicePosition**, **zoomFactor** |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Focus changed | **devicePosition**, **focusPoint** |
| **camera_ui** | ![Info](https://img.shields.io/badge/Info-green) | Preview orientation updated | **orientation**, **videoOrientation** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `camera_switch_failed` | ![Error](https://img.shields.io/badge/Error-red) | Camera switch failed | **previousDevicePosition**, **newDevicePosition** |
| `focus_change_failed` | ![Error](https://img.shields.io/badge/Error-red) | Focus change failed | **devicePosition**, **focusPoint** |
| `torch_not_available` | ![Error](https://img.shields.io/badge/Error-red) | Torch not available on device | **devicePosition** |

---

## ✅ Validation & Completion Events

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **camera_lifecycle** | ![Info](https://img.shields.io/badge/Info-green) | Camera initialization started | (none) |
| **camera_lifecycle** | ![Info](https://img.shields.io/badge/Info-green) | Camera initialized successfully | **devicePosition**, **zoomFactors**, **isAuthorized**, **isTorchAvailable**, **flashMode**, **lensFacing**, **imageFormat**, **isHighResolutionEnabled**, **maxPictureCount**, **maxVideoCount**, **maxMediaCount**, **maxVideoDuration**, **resolution** |
| **camera_lifecycle** | ![Info](https://img.shields.io/badge/Info-green) | Camera operation completed | **clipCount**, **photoCount**, **state** |
| **camera_lifecycle** | ![Warning](https://img.shields.io/badge/Warning-yellow) | Camera dismissed with unsaved media | **clipCount**, **photoCount**, **state** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `camera_initialization_failed` | ![Error](https://img.shields.io/badge/Error-red) | Camera initialization failed | **isAuthorized** |

---

## ⚙️ Camera System Notifications

### Breadcrumbs
| Category | Severity | Message | Metadata |
| -------- | -------- | ------- | -------- |
| **camera_system** | ![Info](https://img.shields.io/badge/Info-green) | Camera services were reset | **state** |
| **camera_system** | ![Info](https://img.shields.io/badge/Info-green) | Camera recovering from reset | **state** |
| **camera_system** | ![Info](https://img.shields.io/badge/Info-green) | Camera recovered from reset | **state** |
| **camera_system** | ![Info](https://img.shields.io/badge/Info-green) | Audio route changed | **reason**, **state** |
| **camera_system** | ![Info](https://img.shields.io/badge/Info-green) | Camera session interrupted | **reason**, **state** |

### Events
| Event Name | Severity | Message | Metadata |
| ---------- | -------- | ------- | -------- |
| `camera_failed_to_recover_from_reset` | ![Error](https://img.shields.io/badge/Error-red) | Camera failed to recover from reset | **state** |
| `audio_route_change_failed` | ![Error](https://img.shields.io/badge/Error-red) | Audio route change failed | **reason**, **state** |
| `camera_runtime_error` | ![Error](https://img.shields.io/badge/Error-red) | Camera runtime error | **errorCode**, **state** |

---

## 📖 Metadata Glossary

Below is a reference of all metadata fields captured across Camera Module telemetry events:

- **aspectRatio** → Current aspect ratio of the preview as string (e.g., `"0.5625"` for 9:16).  
- **clipCount** → Number of video clips currently captured.  
- **codec** → Video codec used for encoding (e.g., `"h264"`, `"hevc"`).  
- **devicePosition** → Active camera position integer value (0 = unspecified, 1 = front, 2 = back).  
- **devices** → Array of device strings in permission prompt (e.g., `["camera", "microphone"]`).  
- **duration** → Length of video recording in seconds (double).  
- **errorCode** → Numeric AVError code (e.g., `-11819`).  
- **flashMode** → Flash setting during capture as string (e.g., `"on"`, `"off"`, `"auto"`).  
- **focusPoint** → Normalized coordinates as string where user tapped to focus (e.g., `"(0.5, 0.5)"`).  
- **hasTorch** → Boolean indicating if the active capture device physically supports a torch.  
- **imageFormat** → Image format setting as string (e.g., `"jpeg"`, `"heif"`).  
- **isAudioAvailable** → Boolean indicating if microphone is available.  
- **isHighResolutionEnabled** → Boolean indicating if high resolution photo capture is enabled.  
- **isTorchAvailable** → Boolean indicating if torch/flash is available.  
- **isTorchEnabled** → Boolean indicating torch state (on/off).  
- **lastZoomFactor** → The zoom factor before magnification gesture (double).  
- **lensFacing** → Initial lens facing preference as string (e.g., `"front"`, `"back"`).  
- **magnificationValue** → Pinch-to-zoom gesture magnification multiplier (double).  
- **maxDuration** → Maximum allowed recording duration in seconds (double).  
- **maxMediaCount** → Maximum total number of media items (photos + videos) allowed (integer).  
- **maxPictureCount** → Maximum number of photos allowed (integer).  
- **maxVideoCount** → Maximum number of video clips allowed (integer).  
- **maxVideoDuration** → Maximum duration for a single video clip in seconds (double).  
- **newDevicePosition** → Camera position after switching (integer value).  
- **orientation** → Device orientation as string (e.g., `"portrait"`, `"landscapeLeft"`, `"landscapeRight"`).  
- **photoCount** → Number of photos currently captured.  
- **previousDevicePosition** → Camera position before switching (integer value).  
- **processorState** → Movie processor state as string (e.g., `"writing"`, `"paused"`).  
- **reason** → Reason code for interruption or route change (integer).  
- **resolution** → Current capture preset as string (e.g., `"hd1920x1080"`, `"hd1280x720"`).  
- **stabilizationMode** → Video stabilization mode (integer value).  
- **state** → Camera recording state as string (e.g., `"initialized"`, `"running"`, `"paused"`, `"finished"`).  
- **status** → Authorization status as string (e.g., `"authorized"`, `"denied"`, `"restricted"`).  
- **videoOrientation** → AVCaptureVideoOrientation as string (e.g., `"portrait"`, `"landscapeLeft"`, `"landscapeRight"`).  
- **zoomFactor** → Current zoom factor applied to the preview (double).  
- **zoomFactors** → Array of available zoom factor values for the device (array of doubles).  

---

📌 This structure ensures:  
- **Global events** stay centralized.  
- **Per-screen events** are self-contained.  
- **Glossary** avoids repetition and makes telemetry fields clear across the repo.  
