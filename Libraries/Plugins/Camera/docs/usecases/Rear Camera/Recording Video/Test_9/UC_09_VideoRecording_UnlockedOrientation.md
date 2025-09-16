# 🎥 Use Case: Video Recording - Record in Multiple Orientations (Unlocked Device Rotation, Rear Camera)  

## 🎯 Objective  
Verify that when recording a video with the **rear camera**, the video correctly adapts to all supported orientations (**portrait, landscape left, landscape right**) when the device orientation is **unlocked**.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording.  
  - Orientation handling while device rotation is **unlocked**.  
  - UI icons (record, pause, flash, zoom, timer) rotate according to device orientation.  

- **Excluded:**  
  - Front camera usage.  
  - Behavior when device orientation is **locked** (covered in a separate test case).  
  - Viewing or validating saved video in Gallery.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** and **microphone permissions**.  
- **Rear camera** is selected.  
- Device orientation lock is **disabled**.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Starts/stops video recording.  

- **Pause Button**  
  - Appears only when recording is active.  

- **Flash Toggle**  
  - Visible, aligned with current orientation.  

- **Zoom Control**  
  - Visible and functional.  

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

- **Device Orientation**  
  - Rotating device (portrait, landscape left, landscape right) → Camera preview and UI icons rotate accordingly, and recording continues seamlessly.  

## 📸 Test Steps  
1. Launch the SDK camera.  
   - Camera preview is displayed.  
2. Switch to **rear camera**.  
   - Rear camera feed is active.  
3. Ensure device orientation lock is **disabled**.  
4. Tap the **Record button** to start recording.  
   - Timer starts counting.  
   - Preview is smooth.  
5. Rotate the device to **landscape left**.  
   - Verify preview rotates.  
   - Verify UI icons rotate and remain aligned.  
   - Recording continues.  
6. Rotate the device to **landscape right**.  
   - Verify preview rotates.  
   - Verify UI icons rotate and remain aligned.  
   - Recording continues.  
7. Rotate the device back to **portrait**.  
   - Verify preview rotates.  
   - Verify UI icons rotate and remain aligned.  
   - Recording continues.  
8. Tap the **Stop button** to end recording.  

### ✅ Expected Result  
- Video recording continues smoothly across **portrait**, **landscape left**, and **landscape right** orientations.  
- Camera preview and UI icons rotate correctly with device orientation.  
- No interruption or corruption occurs when rotating device.  

## ✅ Pass Criteria  
- Recording is seamless across all unlocked orientations.  
- UI icons remain properly aligned after rotation.  
- No crashes, freezes, or misalignment occur.  

## 📎 Notes  
- Test on devices with different screen sizes and aspect ratios.  
- Verify that quick rotations during recording do not cause glitches.  
