# 🎥 Use Case: Capture Photo and Record Video with Flash Mode OFF  

## 🎯 Objective  
Validate that when the SDK camera is configured with `flashMode = .off`, both **photo capture** and **video recording** operations function correctly **without activating any flash or torch light** at any point.  

## 🧪 Test Scope  
- **Included:**  
  - Photo capture with flash disabled.  
  - Video recording initiation and completion with flash disabled.  
  - Verification that torch and flash remain inactive throughout both operations.  
- **Excluded:**  
  - Manual flash toggle interaction.  
  - Exposure and brightness control validation.  
  - HDR or low-light enhancement behavior.  

## 📝 Preconditions  
- SDK camera is initialized with:  
  - `flashMode: .off`  
  - Other configuration parameters set to default.  
- User is authenticated and camera permissions granted.  
- Device supports flash and torch hardware.  
- App is in **foreground** and camera preview visible.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Capture Button**: visible and enabled.  
- **Flash Button**: visible and showing “Off”.  
- **Timer**: visible and updating during recording.  

## 🚫 Expected Hidden UI Elements  
- **Torch Light**: must remain off before, during, and after any operation.  
- **Flash Activation Animation**: must not appear on photo capture or recording start.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap → takes a photo instantly with no flash activation.  
- **Record Button**  
  - Tap once → starts recording video with flash disabled.  
  - Tap again → stops recording and saves video.  
- **Flash Button**  
  - Displays “Off” and remains fixed during both operations.  

## 📸 Test Steps  
1. Launch the SDK camera with configuration `flashMode = .off`.  
2. Verify that the **Flash button** shows “Off”.  
3. Tap the **Capture button** to take a photo.  
   - Observe that no flash or torch light activates.  
4. Review the captured photo.  
   - Confirm consistent lighting and no flash illumination.  
5. Tap the **Record button** to start video recording.  
   - Confirm that flash and torch remain off during recording.  
6. Record for at least **5 seconds** and stop recording.  
7. Review the recorded video.  
   - Confirm no flash activation or light burst occurred.  

### ✅ Expected Result  
- Both photo and video are captured successfully with flash disabled.  
- No torch or flash activation is observed.  
- Lighting in photos and videos remains natural and consistent.  

## ✅ Pass Criteria  
- Flash and torch remain off in all operations.  
- Photo and video are saved correctly without anomalies.  
- UI remains responsive and consistent with configuration.  

## 📎 Notes  
- Execute the test in **both front and rear camera modes**.  
- Repeat in **low-light environments** to ensure no automatic flash triggers.  
- Validate on devices with and without physical flash hardware.  
