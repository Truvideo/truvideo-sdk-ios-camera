# 🎥 Use Case: Start Video Recording with Rear Camera and Flash Enabled  

## 🎯 Objective  
Validate that tapping the **Record button** on the **rear camera** starts video recording with **flash enabled**, ensuring the video is recorded correctly with flash illumination.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording initiation.  
  - Flash state validation (set to ON).  
  - Playback verification to confirm flash illumination during recording.  
- **Excluded:**  
  - Flash OFF or AUTO modes.  
  - Pausing/resuming recording.  
  - Background/foreground transitions.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera and microphone permissions**.  
- **Rear camera** is selected.  
- **Flash toggle** is set to **ON**.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Flash Toggle**: visible, explicitly set to **ON**.  
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
  - Flash remains ON throughout recording.  

## 📸 Test Steps  
1. Launch the SDK camera.
2. Switch to **rear camera**.
3. Ensure **flash toggle is ON**.
4. Tap the **Record button**.
   - Verify timer starts counting.
   - Verify recording indicator is active.
   - Verify flash is ON and illuminating during entire recording.
5. Tap the **Stop button** to finish recording.

### ✅ Expected Result 
- Recording starts correctly with flash enabled.
- Flash remains ON during the entire recording session.
- Playback confirms video was captured with flash illumination.

## ✅ Pass Criteria  
- Flash stays ON from start to finish.
- Video playback is valid and smooth. 
- No crashes, freezes, or unintended flash deactivation.  

## 📎 Notes  
- Validate behavior in **low-light environments** to confirm flash illumination.