# 📷 Use Case: Take Photo with Front Camera  

## 🎯 Objective  
Verify that the user can capture a **photo with the front camera** by pressing the **Capture button**, ensuring the image is correctly saved and displayed in the gallery.  

## 🧪 Test Scope  
- **Included:**
  - Capturing a single photo with the **front camera**.
  - Validation of the shutter sound when the photo is taken (if supported by device).  
  - Ensuring the photo is saved and appears in the gallery.

- **Excluded:**  
  - Flash usage (covered in separate use cases).  
  - Zoom functionality (covered in separate use cases).  
  - Orientation changes.  
  - Interruptions (notifications, calls, background transitions).  

## 📝 Preconditions  
- User is authenticated with valid credentials.  
- The app has been granted **camera** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **front camera**.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and active.  
- **Gallery Button**: visible in idle state.  
- **Zoom Control** (if supported): visible.  

## 🚫 Expected Hidden UI Elements  
- **Flash Toggle**: not visible or disabled (unless specifically supported by front camera).  
- **Resolution Selector**: not validated in this base test.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** (if supported) and save image.  

- **Gallery Button**  
  - Available after capture to access the saved image.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **front camera**.  
3. Tap the **Capture Button**.
   - Verify the **shutter sound** plays (if supported).  
   - Verify the preview does not freeze.
4. Confirm the photo appears in the **gallery**.

### ✅ Expected Result  
- Photo is captured with the **front camera**.  
- **Shutter sound** is heard (if supported).  
- Photo is saved correctly and appears in the gallery.  

## ✅ Pass Criteria  
- The **Capture Button** triggers photo capture consistently.  
- Photo file is saved and accessible in gallery.  
- Camera UI remains responsive without crashes or freezes.  

## 📎 Notes  
- This is the **base case** for photo capture with the **front camera**.  
- Specific use cases for flash, zoom, multiple orientations, interruptions, and resolution changes will be created separately.  
