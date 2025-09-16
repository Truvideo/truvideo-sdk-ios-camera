# 🎥 Use Case: Record Video with Front Camera in Multiple Resolutions  

## 🎯 Objective  
Validate that front camera video recording works correctly across different supported resolutions (HD, FHD, SD).  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in multiple resolutions: HD, FHD, SD.  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
  - Pausing/resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device supports all tested resolutions (HD, FHD, SD).  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Resolution Selector**: visible, allows selection of HD, FHD, or SD.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Resolution Selector**: disabled once recording starts.  
- **Gallery Button**: disabled while recording is active.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Resolution Selector** → Select desired resolution before recording.  
- **Record Button** → Tap → Start recording in the selected resolution.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. For each resolution (HD, FHD, SD)

### ✅ Expected Result  
- Video records successfully in each selected resolution.  
- Resolution selector updates recording resolution correctly.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Recorded video matches selected resolution.  
- Video playback is smooth and intact for all tested resolutions.  

## 📎 Notes  
- Sub-cases exist for HD, FHD, and SD, detailing individual resolution tests. 
