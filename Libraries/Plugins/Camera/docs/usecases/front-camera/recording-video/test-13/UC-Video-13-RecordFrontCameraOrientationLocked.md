# 🎥 Use Case: Record Video with Front Camera When Device Orientation is Locked  

## 🎯 Objective  
Validate that front camera video recording works correctly when the device orientation is **locked**, and the video is recorded in the locked orientation.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video with front camera while orientation lock is enabled.  
- **Excluded:**  
  - Flash, zoom, resolution changes.  
  - Pausing or resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device orientation is **locked**.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Resolution Selector**: disabled once recording starts.  
- **Gallery Button**: disabled while recording is active.  
- **Close (X) Button**: disabled once recording starts. 

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- Orientation lock prevents rotation during recording.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Enable **orientation lock** on the device.  
3. Tap **Record Button** to start recording.  
4. Attempt to rotate the device (orientation should remain locked).  

### ✅ Expected Result  
- Video records successfully in the locked orientation.  
- Orientation lock prevents rotation during recording.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Recorded video matches the locked orientation.  
- UI behaves consistently during recording.  

## 📎 Notes  
- Test in both portrait and landscape orientations with lock enabled.  
- Confirm that orientation cannot be changed during recording.
