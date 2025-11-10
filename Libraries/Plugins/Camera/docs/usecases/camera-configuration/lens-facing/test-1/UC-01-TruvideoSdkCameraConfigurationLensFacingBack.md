# 🎥 Use Case: Configuration Lens Facing Back  

## 🎯 Objective  
Validate that when the SDK camera is configured with `lensFacing = .back`, the camera **initializes and captures** using the **rear camera** only.  

## 🧪 Test Scope  
- **Included:**  
  - Verification that the SDK activates the rear camera as configured.  
  - Validation that the camera preview and captures come from the rear lens.  
- **Excluded:**  
  - Flash, zoom, focus, or image quality validations.  
  - Front camera behavior or manual camera switching.  

## 📝 Preconditions  
- SDK camera initialized with:  
  - `lensFacing: .back`  
  - All other parameters set to default.  
- Device includes both front and rear cameras.  
- User is authenticated and camera permissions granted.  
- App is in **foreground** and camera preview visible.  

## ✅ Expected Visible UI Elements  
- **Camera Preview**: visible and showing image from the rear camera.  
- **Record Button**: visible and enabled.  
- **Capture Button**: visible and enabled.  

## 🚫 Expected Hidden UI Elements  
- **Front Camera Preview**: must not appear.  
- **Camera Switch Button**: hidden or disabled when lens is fixed by configuration.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap → takes a photo using the rear camera.  
- **Record Button**  
  - Tap once → starts recording using the rear camera.  
  - Tap again → stops recording and saves video.  

## 📸 Test Steps  
1. Launch the SDK camera with configuration `lensFacing = .back`.  
2. Confirm that the **preview** displays the **rear camera** feed.  
3. Tap the **Capture button** to take a photo.  
   - Verify the image comes from the rear perspective.  
4. Tap the **Record button** to start video recording.  
   - Confirm the preview still shows the rear camera.  
5. Stop recording and verify the captured video.  
   - Ensure the media corresponds to the rear lens.  

### ✅ Expected Result  
- Both photo and video are captured using the rear camera.  
- The front camera is never activated.  
- Camera switch option remains disabled when configuration is fixed.  

## ✅ Pass Criteria  
- SDK initializes and uses only the rear camera.  
- No unexpected camera switch or preview change occurs.  
- Captured media clearly matches rear camera orientation.  

## 📎 Notes  
- This test validates **only lens configuration behavior**.  
- Other functionalities (flash, zoom, focus) are verified in separate use cases.  
