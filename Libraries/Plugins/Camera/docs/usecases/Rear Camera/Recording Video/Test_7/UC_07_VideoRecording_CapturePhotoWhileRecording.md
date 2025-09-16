# 🎥 Use Case: Video Recording - Capture Photo While Recording  

## 🎯 Objective  
Verify that the user can start recording a video with the rear camera and capture a photo during recording without interrupting the video recording process.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording.  
  - Capturing a photo while video recording is active.  
  - Ensuring video continues recording without interruptions.  

- **Excluded:**  
  - Viewing or validating the saved photo/video in Gallery.  
  - Front camera usage.  
  - Flash or zoom behavior (covered in other test cases).  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- Rear camera is active.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Starts/stops video recording.  

- **Pause Button**  
  - Appears only when recording is active.  

- **Capture Photo Button**  
  - Visible while recording is active.  
  - Captures a photo without stopping the video.  

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

- **Capture Photo Button**  
  - Tap → Saves a photo without interrupting the ongoing video recording.  

## 📸 Test Steps  
1. Launch the SDK camera.  
   - Camera preview is displayed.  
2. Switch to **rear camera**.  
   - Rear camera feed is active.  
3. Tap the **Record button** to start recording.  
   - Timer starts counting.  
   - Video preview is smooth.  
4. Tap the **Capture Photo button** while video is recording.  
   - A photo is captured.  
   - Video continues recording without interruption.  

### ✅ Expected Result  
- Photo is successfully captured during active video recording.  
- Video continues recording without freezes, interruptions, or corruption.  

## ✅ Pass Criteria  
- Video recording is not interrupted when capturing a photo.  
- Both video and photo are saved successfully.  
- No crashes or UI misalignment occur.  

## 📎 Notes  
- Validate that photo capture is instantaneous and does not cause frame drops in the video.  
