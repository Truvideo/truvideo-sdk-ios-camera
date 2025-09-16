# 🎥 Use Case: Video Recording During an Active Call with Front Camera  

## 🎯 Objective  
Validate that front camera video recording behaves correctly when the user receives or is in an active call.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera video recording during an active call.  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
  - Pausing/resuming recording.  
  - Background transitions unrelated to call.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device is in an active call.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled before recording.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- Video recording should handle call audio and state according to platform limitations.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Ensure device is in an active call.  
3. Tap **Record Button** to start recording.  
4. Observe whether recording continues, pauses, or stops based on device behavior. 

### ✅ Expected Result  
- Video recording either continues or handles the call gracefully.  
- Video is saved without corruption.  
- App does not crash.  

## ✅ Pass Criteria  
- Recording behaves according to expected device and OS rules during a call.  
- Video file is intact and playable.  
