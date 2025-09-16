# 🎥 Use Case: Record Video with Audio using Front Camera  

## 🎯 Objective  
Validate that tapping the **Record button** on the **front camera** successfully records video with audio. Ensure that audio is captured when the user speaks during recording.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera video recording with audio.  
  - Audio clarity validation during recording.  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
  - Pausing or resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → recording starts.  
  - Timer starts counting.  
  - Audio captured.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **front camera**.  
3. Tap the **Record button**.  
   - Speak during recording.  
4. Tap **Stop button**.  
5. Play the recorded video.  
   - Verify audio is captured clearly.  

### ✅ Expected Result  
- Video records with synchronized audio and video.  
- No crashes or UI glitches.  

## ✅ Pass Criteria  
- Audio is captured correctly throughout the recording.  
- Video and UI behave as expected.  

## 📎 Notes  
- Test in quiet and moderately noisy environments to verify audio clarity.
