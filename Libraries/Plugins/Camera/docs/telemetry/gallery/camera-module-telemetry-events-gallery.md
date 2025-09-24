# 📊 Camera Module Telemetry Events – Gallery View  

This document defines the **Telemetry events** for the **Gallery View (grid screen)** in the Camera module.  

---
---

## 🌍 Global Events
These global events are tracked across all camera-related screens, including **Media Preview**.  
See [Global Screen View & Breadcrumb Events](./screen-view.md) for details.  

---

## 🖼️ Gallery View (Grid)
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **gallery_opened** | ![Info](https://img.shields.io/badge/Info-green) | User opened the gallery from camera. | **mediaCount** |
| **gallery_closed** | ![Info](https://img.shields.io/badge/Info-green) | User closed the gallery and returned to camera. | **mediaCount** |
| **gallery_media_preview_opened** | ![Info](https://img.shields.io/badge/Info-green) | User tapped and opened a media item (photo or video) from the gallery grid. | **mediaId**, **mediaType**, **index** |

---

## 📖 Metadata Notes
- **mediaId** → Unique identifier for the media item tapped.  
- **mediaType** → `"photo"` or `"video"`.  
- **index** → Position of the media item in the gallery grid.  
- **mediaCount** → Total number of media items in the gallery at the time of event.  
