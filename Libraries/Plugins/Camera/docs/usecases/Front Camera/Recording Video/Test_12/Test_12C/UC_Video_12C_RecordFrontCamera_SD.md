# 🎥 Use Case: Record Video in SD Resolution with Front Camera  

## 🎯 Objective  
Validate that front camera video recording works correctly in **SD resolution**.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in SD resolution.  
- **Excluded:**  
  - Other resolutions, flash, zoom, orientation changes.  
  - Pausing/resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device supports SD video recording.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Resolution Selector**: shows **SD** as selected.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Resolution Selector**: disabled once recording starts.  
- **Gallery Button**: disabled while recording is active.  
- **Close (X) Button**: disabled once recording starts.   

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording in SD resolution.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Select **SD** resolution.

### ✅ Expected Result  
- Video records successfully in SD resolution.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Recorded video resolution is SD.  
- Video playback is smooth and intact.  
