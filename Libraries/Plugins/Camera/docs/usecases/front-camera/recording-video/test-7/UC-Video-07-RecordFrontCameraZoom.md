# 🎥 Use Case: Record Video and Adjust Zoom with Front Camera  

## 🎯 Objective  
Validate that the user can adjust the camera zoom while recording a video with the front camera.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera video recording.  
  - Dynamic zoom adjustments during recording.  
- **Excluded:**  
  - Flash, orientation changes.  
  - Pausing or resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Zoom controls are available for the front camera.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Zoom Slider / Pinch Control**: visible and adjustable.  
- **Timer**: default **00:00:00**, visible before recording.

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- **Zoom Control** → Adjust zoom during recording.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Tap **Record Button** to start recording.  
3. Adjust the zoom slider or use pinch gesture.

### ✅ Expected Result  
- Video records successfully with zoom adjustments applied.  
- No crashes or UI glitches occur.  

## ✅ Pass Criteria  
- Zoom changes are correctly reflected in the saved video.  
- Video recording is uninterrupted.  

## 📎 Notes  
- Test with different zoom levels.
