# 🎥 Use Case: Start Video Recording with Front Camera  

## 🎯 Objective  
Verify the general functionality of **video recording using the front camera**, ensuring the base workflow is stable and can be extended with specific features such as audio recording, flash control, pause/resume, zoom, orientation handling, background transitions, and interruptions (calls or notifications).  

## 🧪 Test Scope  
- **Included:**  
  - General validation of starting and stopping video recording with the **front camera**.  
  - Ensuring stability as the foundation for all extended video recording functionalities.  

- **Excluded:**  
  - Specific validations of flash, pause/resume, zoom, orientation, background transitions, calls, or notifications (covered in dedicated use cases).  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** and **microphone** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **front camera**.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible in idle state.  
- **Timer**: default **00:00:00** in white, starts once recording begins.  
- **Flash Toggle**: visible (ON/OFF options, if supported).  
- **Zoom Control**: available for adjustments during recording.  
- **Capture Photo Button (while recording)**: visible and functional.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → start recording.  
  - Tap again → stop recording and save video.  

- **Flash Toggle / Zoom / Capture Photo Button**  
  - Functional during recording, but validated in specific test cases.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **front camera**.  
3. Tap the **Record Button** to start recording.  
   - Verify timer starts counting.  
   - Verify preview remains smooth.  
4. Tap the **Record Button** again to stop recording.  
5. Verify the video is saved correctly.  

### ✅ Expected Result  
- The user can start and stop video recording with the front camera.  
- Recorded video is saved successfully with no corruption.  

## ✅ Pass Criteria  
- Video starts and stops without issues.  
- No freezes, black screens, or crashes.  
- Video file is playable and contains valid frames.  

## 📎 Notes  
- This general case validates only the **core recording workflow**.  
- The following **specific use cases** extend and validate particular functionalities:  

  - UC_Video_01_RecordFrontCamera  
  - UC_Video_02_RecordFrontCameraWithAudio  
  - UC_Video_03_RecordFrontCameraNoFlash  
  - UC_Video_04_RecordFrontCameraPause  
  - UC_Video_05_RecordFrontCameraPauseResume  
  - UC_Video_06_RecordFrontCameraPhotoWhileRecording  
  - UC_Video_07_RecordFrontCameraZoom  
  - UC_Video_08_RecordFrontCameraMultipleOrientations  
    - UC_Video_8A_RecordFrontCamera_Portrait  
    - UC_Video_8B_RecordFrontCamera_LandscapeLeft  
    - UC_Video_8C_RecordFrontCamera_LandscapeRight  
  - UC_Video_09_RecordFrontCameraBackgroundTransition  
  - UC_Video_10_RecordFrontCameraDuringCall  
  - UC_Video_11_RecordFrontCameraDuringNotification  
  - UC_Video_12_RecordFrontCameraMultipleResolutions.md  
    - UC_Video_12A_RecordFrontCamera_HD.md  
    - UC_Video_12B_RecordFrontCamera_FHD.md  
    - UC_Video_12C_RecordFrontCamera_SD.md  
  - UC_Video_13_RecordFrontCameraOrientationLocked.md
