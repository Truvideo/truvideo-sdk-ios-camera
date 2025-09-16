# 🎥 Use Case: Start Video Recording with Rear Camera and Audio  

## 🎯 Objective  
Validate that tapping the **Record button** on the **rear camera** starts video recording **with audio captured from the microphone**.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording initiation.  
  - Microphone audio capture during recording.  
  - Audio playback verification after recording.  
- **Excluded:**  
  - Pausing/resuming recording.  
  - Flash toggle, zoom, orientation changes.  
  - Behavior under background or call interruptions.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- **Rear camera** is selected.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.
- **Gallery Button**: disabled while recording is active. 
- **Resolution Selector**: disabled once recording starts.
- **Close (X) Button**: disabled once recording starts.

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → recording starts with both video and audio.  
  - Timer starts counting.  
  - UI switches to recording state.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Tap the **Record button**.  
   - Verify timer starts counting.  
   - Verify recording indicator (e.g., red timer background) is active.  
   - Verify microphone input is active.  
4. Speak into the microphone while recording.  
5. Tap the **Stop button** to finish recording.

### ✅ Expected Result  
- Tapping the **Record button** starts video recording with audio.  
- Microphone captures user’s voice during recording.  
- Playback shows synchronized video and audio.  

## ✅ Pass Criteria  
- Recording starts correctly with audio.  
- Audio is clear and synchronized in playback.  
- No crashes, freezes, or missing audio segments.  

## 📎 Notes  
- Validate in **quiet** and **noisy** environments.  
- Test with **headphones connected** and **without headphones**.  
- Compare with OS restrictions (some devices may reduce audio quality during recording). 