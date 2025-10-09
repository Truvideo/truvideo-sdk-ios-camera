# 🎥 Use Case: Record Video in Multiple Orientations with Front Camera  

## 🎯 Objective  
Validate that front camera video recording works correctly in different device orientations when orientation lock is disabled.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in **portrait**, **landscape-left**, and **landscape-right** orientations.  
- **Excluded:**  
  - Flash, zoom, audio verification.  
  - Pausing or resuming recording.  
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
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- Rotate device → Recording continues in new orientation.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Ensure device orientation lock is disabled.  
3. Tap **Record Button** to start recording.  
4. Rotate the device through **portrait**, **landscape**, and **upside-down** orientations.  
5. Tap **Stop Button** to finish recording.  
6. Play video and verify orientation changes are correctly reflected.  

### ✅ Expected Result  
- Video records successfully in multiple orientations.  
- Orientation changes are correctly captured in the saved video.  

## ✅ Pass Criteria  
- Video playback reflects all device orientation changes.  
- No UI glitches or recording interruptions occur.  

## 📎 Notes  
- Test quickly switching between orientations.
