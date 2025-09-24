# 📊 Camera Module Telemetry Events

This document defines the **Telemetry events** used to track interactions, states, and system notifications in the Camera module.  
It includes **global events** that apply across the entire camera flow and links to **per-screen documentation** where more specific events are described.  

---

## 🌍 Global Events
Global events are tracked independently and apply to all camera flows.  

### 🖥️ Screen View Tracking
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **screen_view** | ![Info](https://img.shields.io/badge/Info-green) | User navigated to a specific screen/view in the Camera module. | **screenName** |

### 📐 Breadcrumbs
| Event Name | Severity | Description | Metadata | Source |
| ---------- | -------- | ----------- | -------- | ------ |
| **orientation_changed** | ![Info](https://img.shields.io/badge/Info-green) | Device orientation changed during camera usage. | **previousOrientation**, **newOrientation** | Sensors |

### 📖 Metadata Notes
- **screenName** → Identifier for the current screen (e.g., `"camera_capture"`, `"camera_recording"`, `"gallery_view"`, `"media_preview"`).  
- **previousOrientation** → The prior device orientation (`portrait`, `landscape_left`, `landscape_right`, `portrait_upside_down`).  
- **newOrientation** → The updated device orientation after the change.  

---

## 📑 Per-Screen Telemetry Documentation
Each screen or module within the Camera flow has its own telemetry specification.  

- 📸 **Capture Photo Events** → [`./capture/capture-photo.md`](./capture/capture-photo.md)  
- 🎥 **Recording Video Events** → [`./capture/recording-video.md`](./capture/recording-video.md)  
- 🖼️ **Gallery View Events** → [`./gallery/gallery-view.md`](./gallery/gallery-view.md)  
- 📺 **Media Preview (Full Screen) Events** → [`./gallery/media-preview.md`](./gallery/media-preview.md)  
- ⚙️ **System Notifications Events** → [`./system/system-notifications.md`](./system/system-notifications.md)  
