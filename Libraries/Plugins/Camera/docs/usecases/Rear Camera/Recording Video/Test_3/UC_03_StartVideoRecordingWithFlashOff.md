# 🎥 Use Case: Start Video Recording with Rear Camera and Flash Disabled  

## 🎯 Objective  
Validate that tapping the **Record button** on the **rear camera** starts video recording with **flash disabled**, ensuring the video is recorded correctly without flash illumination.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording initiation.  
  - Flash state validation (set to OFF).  
  - Playback verification to confirm no flash illumination during recording.  
- **Excluded:**  
  - Flash ON modes.  
  - Pausing/resuming recording.  
  - Background/foreground transitions.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera and microphone permissions**.  
- **Rear camera** is selected.  
- **Flash toggle** is set to **OFF**.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Flash Toggle**: visible, explicitly set to **OFF**.  
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
  - Flash remains OFF throughout recording.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Ensure **flash toggle is OFF**.  
4. Tap the **Record button**.  
   - Verify timer starts counting.  
   - Verify recording indicator is active.  
   - Verify flash remains OFF during entire recording.  
5. Tap the **Stop button** to finish recording.  

### ✅ Expected Result  
- Recording starts correctly with flash disabled.  
- Flash remains OFF during the entire recording session.  
- Playback confirms video was captured without flash illumination.  

## ✅ Pass Criteria  
- Flash stays OFF from start to finish.  
- Video playback is valid and smooth.  
- No crashes, freezes, or unintended flash activation.  