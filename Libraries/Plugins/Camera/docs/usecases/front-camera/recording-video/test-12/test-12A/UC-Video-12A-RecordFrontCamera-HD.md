# 🎥 Use Case: Record Video in HD Resolution with Front Camera  

## 🎯 Objective  
Validate that front camera video recording works correctly in **HD resolution**.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in HD resolution (1280x720).  
- **Excluded:**  
  - Other resolutions, flash, zoom, orientation changes.  
  - Pausing/resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device supports HD video recording.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Resolution Selector**: shows **HD** as selected.  
- **Timer**: default **00:00:00**, visible before recording. 

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Resolution Selector**: disabled once recording starts.  
- **Gallery Button**: disabled while recording is active.  
- **Close (X) Button**: disabled once recording starts.   

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording in HD resolution.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Select **HD** resolution.

### ✅ Expected Result  
- Video records successfully in HD resolution.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Recorded video resolution is (HD).  
- Video playback is smooth and intact.  
