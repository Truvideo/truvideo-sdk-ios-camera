# 📷 Use Case: Take Photo with Flash On (Rear Camera)  

## 🎯 Objective  
Verify that when the **flash is turned ON**, the user can capture a **photo with the rear camera** by pressing the **Take Photo button**, ensuring the flash illuminates correctly, the photo is saved successfully, and the shutter sound is played.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a photo with **rear camera** and **flash enabled**.  
  - Validation that the flash illuminates during capture.  
  - Shutter sound validation.  

- **Excluded:**  
  - Capturing with flash OFF (covered in another test).  
  - Zoom, orientation changes, or burst mode.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** and **microphone** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **rear camera** with flash support.  
- **Flash toggle is set to ON** before capturing.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible and set to **ON**.  
- **Zoom Control**: visible.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while camera is in idle preview.  
- **Resolution Selector**: not available during capture.  

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** and save image **with flash illumination**.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **rear camera**.  
3. Ensure **Flash toggle is set to ON**.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** is played.  
   - Verify **flash illuminates** when capturing.  
   - Verify the preview does not freeze.  
5. Confirm the photo is saved successfully.  

### ✅ Expected Result  
- Photo is captured with the **rear camera**.  
- **Shutter sound** is heard when the photo is taken.  
- **Flash activates** during capture.  
- Photo is saved correctly and is not corrupted.  

## ✅ Pass Criteria  
- The **Take Photo button** works correctly with flash ON.  
- Shutter sound is always played.  
- Flash illuminates during photo capture.  
- Photo file is saved successfully.  
- No crashes or preview freezes occur.  

## 📎 Notes  
- This case validates specifically **flash ON photo capture**.  
- Additional flash behaviors (e.g., OFF or AUTO) are tested in separate cases.  
