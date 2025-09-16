# 🎥 Use Case: Video Recording During an Active Call  

## 🎯 Objective  
Verify that the user can successfully record a video with the **rear camera** while an **active phone call** is ongoing, ensuring that the camera does not freeze and the video is saved correctly.  

## 🧪 Test Scope  
- **Included:**  
  - Video recording behavior during an active call.  
  - Camera preview stability during call.  
  - Video playback validation after recording. 
- **Excluded:**
  - Flash, zoom, resolution changes.  
  - Pausing/resuming recording.  
  - Capturing photos while recording.  
  - Call audio quality or routing validation.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is initialized and active.  
- Device has **camera** and **microphone permissions** granted.  
- An **active phone or VoIP call** is in progress.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Visible in idle state.  
  - Starts/stops recording normally, even if a call is active.  
- **Timer**  
  - Starts counting once recording begins.  
  - Must remain responsive during the call.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Must trigger recording successfully despite the active call.  
- **System Behavior**  
  - Camera preview must remain stable.  
  - App must not crash or freeze during recording.  

## 📸 Test Steps  
1. Initiate a **phone or VoIP call** on the device.  
2. Launch the SDK camera.  
3. Switch to the **rear camera**.  
4. Tap the **Record button** to start recording.  
   - Verify the **timer starts counting**.  
   - Verify the **camera preview remains smooth** (no freezes).  
5. Speak or generate sound to confirm microphone input behavior (if allowed during call).  

### ✅ Expected Result  
- Video recording works correctly during an active call.  
- No freezes, black screens, or crashes occur. 

## ✅ Pass Criteria  
- Video is recorded successfully while a call is active.  
- Camera preview remains stable throughout the process.  
- Playback shows valid video.  
- App remains stable and responsive.  

## 📎 Notes  
- Must be tested in both **portrait** and **landscape** orientations.  