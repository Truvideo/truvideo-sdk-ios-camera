# 🎥 Use Case: Record Video in Landscape Left Orientation with Front Camera  

## 🎯 Objective  
Validate that front camera video recording works correctly in **landscape-left orientation** when device orientation is not locked.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in landscape-left orientation.  
- **Excluded:**  
  - Portrait or landscape-right orientations, flash, zoom, audio, pausing/resuming.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device orientation lock is **disabled**.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording in landscape-left orientation.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Ensure device orientation lock is disabled.  
3. Rotate device to **landscape-left orientation**.  
4. Tap **Record Button** to start recording. 

### ✅ Expected Result  
- Video records correctly in landscape-left orientation.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Recorded video is in landscape-left orientation.  
- UI behaves as expected during recording.  
