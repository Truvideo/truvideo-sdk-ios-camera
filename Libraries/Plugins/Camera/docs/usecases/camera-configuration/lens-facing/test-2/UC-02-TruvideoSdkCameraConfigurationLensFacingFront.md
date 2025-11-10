# 🎥 Use Case: Configuration Lens Facing Front  

## 🎯 Objective  
Validate that when the SDK camera is configured with `lensFacing = .front`, the camera **initializes and captures** using the **front camera** only.  

## 🧪 Test Scope  
- **Included:**  
  - Verification that the SDK activates the front camera as configured.  
  - Validation that the preview and captures are from the front lens.  
- **Excluded:**  
  - Flash, zoom, focus, or image quality validations.  
  - Rear camera behavior or camera switching logic.  

## 📝 Preconditions  
- SDK camera initialized with:  
  - `lensFacing: .front`  
  - All other parameters set to default.  
- Device includes both front and rear cameras.  
- User is authenticated and camera permissions granted.  
- App is in **foreground** and camera preview visible.  

## ✅ Expected Visible UI Elements  
- **Camera Preview**: visible and showing image from the front camera.  
- **Record Button**: visible and enabled.  
- **Capture Button**: visible and enabled.  

## 🚫 Expected Hidden UI Elements  
- **Rear Camera Preview**: must not appear.  
- **Camera Switch Button**: hidden or disabled when lens is fixed by configuration.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap → takes a photo using the front camera.  
- **Record Button**  
  - Tap once → starts recording using the front camera.  
  - Tap again → stops recording and saves video.  

## 📸 Test Steps  
1. Launch the SDK camera with configuration `lensFacing = .front`.  
2. Confirm that the **preview** displays the **front camera** feed.  
3. Tap the **Capture button** to take a photo.  
   - Verify the image comes from the front perspective.  
4. Tap the **Record button** to start video recording.  
   - Confirm the preview still shows the front camera.  
5. Stop recording and verify the captured video.  
   - Ensure the media corresponds to the front lens.  

### ✅ Expected Result  
- Both photo and video are captured using the front camera.  
- The rear camera is never activated.  
- Camera switch option remains disabled when configuration is fixed.  

## ✅ Pass Criteria  
- SDK initializes and uses only the front camera.  
- No unexpected camera switch or preview change occurs.  
- Captured media clearly matches front camera orientation.  

## 📎 Notes  
- This test validates **only lens configuration behavior**.  
- Other functionalities (flash, zoom, focus) are verified in separate use cases.  
