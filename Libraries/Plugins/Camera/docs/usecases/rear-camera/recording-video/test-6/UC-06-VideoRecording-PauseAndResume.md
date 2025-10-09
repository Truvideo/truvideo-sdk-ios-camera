# 🎥 Use Case: Record Video, Pause, and Resume  

## 🎯 Objective  
Verify that when recording a video with the **rear camera**, pressing the **Pause button** pauses the recording, and pressing the **Resume button** resumes the recording without errors.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording.  
  - Pause and resume functionality during recording.  

- **Excluded:**  
  - Flash functionality.  
  - Front camera.  
  - App background/foreground transitions.  

## 📝 Preconditions  
- Device has granted **camera** and **microphone permissions**.  
- SDK camera is installed, initialized, and launched.  
- User is authenticated.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Starts/stops recording.  

- **Pause Button**  
  - Becomes visible once recording starts.  
  - Pauses the recording when tapped.  

- **Resume Button**  
  - Replaces **Pause button** after pausing.  
  - Resumes recording when tapped.  

- **Timer**  
  - Starts counting when recording begins.  
  - Stops counting when paused.  
  - Resumes counting when recording is resumed.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- Tapping **Pause button** must stop both video and audio recording.  
- Tapping **Resume button** must continue both video and audio recording.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Tap the **Record button** to start recording.  
   - Verify timer starts counting.  
   - Verify preview is smooth.  
4. Tap the **Pause button**.  
   - Verify timer stops.  
   - Verify preview remains active but recording is paused.  
5. Tap the **Resume button**.  
   - Verify timer resumes counting.  
   - Verify video and audio recording resume correctly.  

**Expected Result:**  
- Recording pauses when the **Pause button** is pressed.  
- Recording resumes correctly when the **Resume button** is pressed.  

## ✅ Pass Criteria  
- Pause and resume work without errors.  
- No app freeze or crash occurs.   
