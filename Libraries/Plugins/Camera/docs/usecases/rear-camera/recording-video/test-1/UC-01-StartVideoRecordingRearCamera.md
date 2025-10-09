# 🎥 Use Case: Start Video Recording with Rear Camera  

## 🎯 Objective  
Validate that tapping the **Record button** on the **rear camera** successfully starts video recording.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording initiation.  
  - Timer behavior on start.  
  - Recording state validation.  
- **Excluded:**  
  - Stopping, pausing, resuming recording.  
  - Flash toggle, zoom, orientation changes.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- **Rear camera** is selected.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Flash Toggle / Zoom Control**: visible in idle state.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.
- **Gallery Button**: disabled while recording is active. 
- **Resolution Selector**: disabled once recording starts.
- **Close (X) Button**: disabled once recording starts.

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → recording starts.  
  - Timer starts counting.  
  - UI switches to recording state.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Tap the **Record button**.  
   - Verify timer starts counting.  
   - Verify recording indicator (e.g., red timer background) is active.  
   - Verify UI transitions into recording state.  

### ✅ Expected Result  
- Tapping the **Record button** starts video recording with the rear camera.  
- Timer increments from **00:00:00**.  
- No crashes, freezes, or black screen appear.  

## ✅ Pass Criteria  
- Recording starts correctly when Record button is tapped.  
- Timer displays elapsed recording time.  
- UI reflects active recording state.  

## 📎 Notes  
- Validate in **portrait** and **landscape** orientations. 