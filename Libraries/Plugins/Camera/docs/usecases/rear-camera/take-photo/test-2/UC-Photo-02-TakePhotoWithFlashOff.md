# 📷 Use Case: Take Photo with Flash Off (Rear Camera)  

## 🎯 Objective  
Verify that when the **flash is turned OFF**, the user can capture a **photo with the rear camera** by pressing the **Take Photo button**, ensuring the photo is saved correctly without flash illumination and the shutter sound is played.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a photo with **rear camera** and **flash disabled**.  
  - Validation that the photo is taken without flash illumination.  
  - Shutter sound validation.  

- **Excluded:**  
  - Capturing with flash enabled (covered in another test).  
  - Zoom usage.  
  - Orientation handling.  
  - Burst mode or multiple photos.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** and **microphone** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **rear camera** with flash support.  
- **Flash toggle is set to OFF** before capturing.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible and set to **OFF**.  
- **Zoom Control**: visible.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while camera is in idle preview.  
- **Resolution Selector**: not available during capture.  

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** and save image **without flash**.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **rear camera**.  
3. Ensure **Flash toggle is set to OFF**.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** is played.  
   - Verify **flash does not illuminate**.  
   - Verify the preview does not freeze.  
5. Confirm the photo is saved successfully.  

### ✅ Expected Result  
- Photo is captured with the **rear camera**.  
- **Shutter sound** is heard when the photo is taken.  
- **Flash does not turn on** during capture.  
- Photo is saved correctly and is not corrupted.  

## ✅ Pass Criteria  
- The **Take Photo button** works correctly with flash OFF.  
- Shutter sound is always played.  
- Photo file is saved successfully.  
- Flash never activates during this test.  
- No crashes or preview freezes occur.  

## 📎 Notes  
- This case validates specifically **flash OFF photo capture**.  
- Additional flash behaviors (e.g., ON or AUTO) are tested separately.  
