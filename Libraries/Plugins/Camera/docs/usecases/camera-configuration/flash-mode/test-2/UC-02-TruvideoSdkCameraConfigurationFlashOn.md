# 🎥 Use Case: Capture Photo and Record Video with Flash Mode ON  

## 🎯 Objective  
Validate that when the SDK camera is configured with `flashMode = .on`, both **photo capture** and **video recording** correctly activate the device’s flash or torch light, ensuring proper illumination during capture and recording.  

## 🧪 Test Scope  
- **Included:**  
  - Photo capture behavior with flash enabled.  
  - Video recording behavior with torch (continuous flash) active.  
  - Validation that flash or torch activates consistently and stays on during recording.  
- **Excluded:**  
  - Manual flash button interaction.  
  - Automatic exposure or brightness correction validation.  
  - HDR, night mode, or adaptive lighting algorithms.  

## 📝 Preconditions  
- SDK camera initialized with:  
  - `flashMode: .on`  
  - All other parameters set to default.  
- User is authenticated and camera permissions granted.  
- Device supports hardware flash/torch.  
- App is in **foreground** and camera preview visible.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Capture Button**: visible and enabled.  
- **Flash Button**: visible and showing “On”.  
- **Timer**: visible and updating during recording.  

## 🚫 Expected Hidden UI Elements  
- **Flash Toggle Animation**: should not flicker or reset unexpectedly.  
- **Flash Auto Mode Indicator**: not shown when configuration explicitly sets flash to `on`.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap → triggers a photo capture with a visible flash burst.  
- **Record Button**  
  - Tap once → starts recording with torch light turned on automatically.  
  - Tap again → stops recording, torch light turns off immediately.  
- **Flash Button**  
  - Displays “On” and remains fixed during operations.  

## 📸 Test Steps  
1. Launch the SDK camera with configuration `flashMode = .on`.  
2. Verify that the **Flash button** displays “On”.  
3. Tap the **Capture button** to take a photo.  
   - Observe a flash burst occurs during capture.  
4. Review the captured photo.  
   - Confirm the subject is illuminated and flash activated.  
5. Tap the **Record button** to start recording.  
   - Confirm the torch light turns on and stays on during recording.  
6. Record for at least **5 seconds**.  
7. Tap the **Record button** again to stop recording.  
   - Verify the torch turns off immediately after stopping.  
8. Review the recorded video.  
   - Confirm consistent lighting and no premature flash deactivation.  

### ✅ Expected Result  
- Flash activates during photo capture.  
- Torch light remains active throughout video recording.  
- Both operations complete successfully with correct illumination behavior.  

## ✅ Pass Criteria  
- Flash or torch consistently activates according to configuration.  
- Photo and video files are saved correctly and well lit.  
- No UI lag, flicker, or desynchronization occurs.  

## 📎 Notes  
- Test in both **front** and **rear** camera modes (front cameras may ignore flash setting).  
- Validate in **low-light environments** to confirm flash activation reliability.  
- Confirm torch deactivates even if recording ends due to app interruption or error.  
