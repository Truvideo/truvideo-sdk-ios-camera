# 🎥 Use Case: Video Recording - Adjust Zoom While Recording (Rear Camera)  

## 🎯 Objective  
Verify that when recording a video with the **rear camera**, the user can adjust the zoom level while recording is active without interrupting or affecting the video recording process.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording.  
  - Adjusting zoom during active video recording.  
  - Ensuring smooth preview while zoom is adjusted.  

- **Excluded:**  
  - Front camera usage.  
  - Flash or photo capture (covered in other test cases).  
  - Viewing or validating saved video in Gallery.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- **Rear camera** is selected.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Starts/stops video recording.  

- **Pause Button**  
  - Appears only when recording is active.  

- **Zoom Control** (slider or pinch gesture)  
  - Visible and functional during recording.  

- **Timer**  
  - Default: **00:00:00**.  
  - Increments once recording starts.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap → Starts/stops recording.  

- **Pause Button**  
  - Tap → Pauses/resumes recording.  

- **Zoom Control**  
  - Adjust (slider/pinch gesture) → Camera preview and recording adjust zoom smoothly without interruptions.  

## 📸 Test Steps  
1. Launch the SDK camera.  
   - Camera preview is displayed.  
2. Switch to **rear camera**.  
   - Rear camera feed is active.  
3. Tap the **Record button** to start recording.  
   - Timer starts counting.  
   - Video preview is smooth.  
4. Adjust the **zoom control** (slider or pinch gesture).  
   - Verify zoom adjusts in real time.  
   - Verify recording continues smoothly without freezes or interruptions. 

### ✅ Expected Result  
- Zoom can be adjusted during active **rear camera** video recording.  
- Video recording continues smoothly while zoom changes.  
- Preview reflects zoom adjustments without stutter or corruption.  

## ✅ Pass Criteria  
- Zoom is functional and responsive during recording.  
- Recording remains uninterrupted and stable.  
- No crashes or UI misalignment occur.  

## 📎 Notes  
- Test with different zoom levels (minimum, mid, maximum).  