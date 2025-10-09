# 📷 Use Case: Take Photo with Rear Camera  

## 🎯 Objective  
Verify that the user can capture a **photo with the rear camera** by pressing the **Take Photo button**, ensuring the image is correctly saved and the shutter sound is played.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a single photo with the **rear camera**.  
  - Validation of the shutter sound when the photo is taken.  
  - Ensuring the photo is saved correctly.  

- **Excluded:**  
  - Flash usage (covered in specific use cases).  
  - Zoom adjustments before capturing.  
  - Orientation handling. 

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** and **microphone** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **rear camera**.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in active state.  
- **Flash Toggle**: visible (ON/OFF options).  
- **Zoom Control**: visible.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while camera is in idle preview. 
- **Resolution Selector**: not available during capture. 

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** and save image.  

- **Flash / Zoom Controls**  
  - Available but not validated in this test case.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **rear camera**.  
3. Tap the **Take Photo Button**.  
   - Verify the **shutter sound** is played.  
   - Verify the preview does not freeze.  
4. Confirm the photo is saved successfully.  

### ✅ Expected Result  
- Photo is captured with the **rear camera**.  
- **Shutter sound** is heard when the photo is taken.  
- Photo is saved correctly and is not corrupted.  

## ✅ Pass Criteria  
- The **Take Photo button** works correctly.  
- Shutter sound is always played when capturing.  
- Photo file is saved and accessible.  
- No crashes or preview freezes occur.  

## 📎 Notes  
- This is the **base case** for photo capture with the rear camera.  
- Specific use cases for flash, zoom, and orientation will be created separately.  
