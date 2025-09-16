# 📷 Use Case: Take Photo While Adjusting Zoom (Rear Camera)  

## 🎯 Objective  
Verify that the user can **adjust the zoom** of the rear camera while taking a photo, ensuring the zoom level is applied correctly in the captured image, and the shutter sound is played when the photo is taken.  

## 🧪 Test Scope  
- **Included:**  
  - Taking a photo with the **rear camera**.  
  - Adjusting **zoom level** before capture.  
  - Validation of the shutter sound during capture.  

- **Excluded:**  
  - Flash ON/OFF behavior (covered in other cases).  
  - Orientation changes while capturing photos.  
  - Burst photo mode.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** and **microphone** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **rear camera** with zoom capability.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Zoom Control**: visible and functional.  
- **Flash Toggle**: visible but not required for this test.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while camera is in idle preview.  
- **Resolution Selector**: not available during capture.  

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** and save image at the applied zoom level.  

- **Zoom Control**  
  - Adjust before pressing Take Photo → preview must update smoothly.  
  - Captured photo must reflect the zoom level set.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **rear camera**.  
3. Adjust the **zoom control** to a specific level (e.g., 2x).  
   - Verify that the preview updates correctly.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** is played.  
   - Verify the photo is saved **with the applied zoom level**.  

### ✅ Expected Result  
- Photo is captured successfully with the **applied zoom level**.  
- **Shutter sound** is heard during capture.  
- The preview and final photo match the selected zoom level.  

## ✅ Pass Criteria  
- Zoom control updates the preview smoothly.  
- Captured photo reflects the zoom level selected.  
- Shutter sound is always played.  
- Photo file is saved successfully and not corrupted.  
- No crashes or freezes occur.  

## 📎 Notes  
- Test with different zoom levels (e.g., 1x, 2x, max zoom). 
