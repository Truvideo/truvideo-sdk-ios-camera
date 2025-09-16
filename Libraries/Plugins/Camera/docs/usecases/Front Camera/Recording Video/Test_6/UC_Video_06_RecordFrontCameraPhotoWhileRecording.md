# 🎥 Use Case: Record Video and Take Photo with Front Camera  

## 🎯 Objective  
Validate that a photo can be taken while recording a video with the front camera, without interrupting the video.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video with front camera.  
  - Capturing photo during recording.  
- **Excluded:**  
  - Pausing/resuming recording.  
  - Flash, zoom, orientation changes.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Take Photo Button**: visible during recording.  
- **Timer**: visible and counting while recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause/Resume Buttons**: optional, hidden until used.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- **Take Photo Button** → Tap → Capture photo without interrupting video.  

## 📸 Test Steps  
1. Launch SDK camera and select **front camera**.  
2. Tap **Record Button** to start video recording.  
3. Tap **Take Photo Button** during recording.  
   - Verify photo is captured and saved. 

### ✅ Expected Result  
- Photo is saved successfully while video recording continues.  
- Video recording is uninterrupted.  

## ✅ Pass Criteria  
- Video and photo are saved correctly.  
- UI behaves as expected with no glitches or crashes.  
