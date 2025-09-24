# 📊 Camera Module Telemetry Events – Media Preview (Full Screen)

This document defines the **Telemetry events** for the **Media Preview screen** (`MediaPreviewPageViewController`).  
This screen is responsible for **full-screen viewing of photos and videos**, allowing users to swipe between media items, delete content, and (for videos) start playback.  

---

## 🌍 Global Events
These global events are tracked across all camera-related screens, including **Media Preview**.  
See [Global Screen View & Breadcrumb Events](./screen-view.md) for details.  

---

## 📺 Media Viewing
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **media_preview_opened** | ![Info](https://img.shields.io/badge/Info-green) | User opened a media item in full-screen preview. | **mediaId**, **mediaType**, **index** |
| **media_preview_changed** | ![Info](https://img.shields.io/badge/Info-green) | User swiped to a different media item. | **mediaId**, **mediaType**, **index** |
| **media_preview_closed** | ![Info](https://img.shields.io/badge/Info-green) | User closed the full-screen media preview. | **mediaId**, **mediaType**, **index** |

---

## ▶️ Video Playback
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **media_preview_video_play** | ![Info](https://img.shields.io/badge/Info-green) | User started video playback in preview. | **mediaId**, **index**, **duration** |

---

## 🗑️ Media Deletion
| Event Name | Severity | Description | Metadata |
| ---------- | -------- | ----------- | -------- |
| **media_preview_delete_succeeded** | ![Info](https://img.shields.io/badge/Info-green) | User deleted a media item successfully. | **mediaId**, **mediaType**, **index** |
| **media_preview_delete_failed** | ![Error](https://img.shields.io/badge/Error-red) | An error occurred while attempting to delete a media item. | **mediaId**, **mediaType**, **index**, **error** |

---

## 📖 Metadata Notes
- **mediaId** → Unique identifier for the media item.  
- **mediaType** → `"photo"` or `"video"`.  
- **index** → Position of the media item in the preview sequence.  
- **duration** → Length of video (only for videos).  
- **error** → Human-readable error if deletion or playback fails.  
