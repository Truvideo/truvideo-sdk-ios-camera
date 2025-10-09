# 📷 Use Case: Take Photo with Front Camera  

## 🎯 Objective  
Verify the general functionality of **taking photos using the front camera**, ensuring the base workflow is stable and can be extended with specific features such as flash control, zoom, orientation handling, background interruptions (calls or notifications), and resolution adjustments.  

## 🧪 Test Scope  
- **Included:**  
  - General validation of capturing a photo with the **front camera**.  
  - Ensuring stability as the foundation for all extended photo functionalities.  

- **Excluded:**  
  - Specific validations of flash, zoom, orientation, resolution, calls, or notifications (covered in dedicated use cases).  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** permissions.  
- SDK camera is properly initialized and launched.  
- Device has a functional **front camera**.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Flash Toggle**: visible (ON/OFF options if supported).  
- **Zoom Control**: available for adjustments.  
- **Camera Switch Button**: visible and functional.  

## 🚫 Expected Hidden UI Elements  
- Gallery, Timer, or other recording-related buttons remain hidden.  

## ✋ Interaction Rules  
- **Capture Button**  
  - Tap once → take photo.  
- **Flash Toggle / Zoom Control / Camera Switch**  
  - Functional, but validated in specific test cases.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **front camera**.  
3. Verify **UI elements** (Capture Button, Flash Toggle, Zoom, Camera Switch) are visible.  
4. Tap the **Capture Button**.  
5. Verify the photo is saved correctly.  
6. Optionally adjust **flash**, **zoom**, or **orientation** and repeat capture.  

### ✅ Expected Result  
- The user can capture a photo with the front camera.  
- Photo is saved successfully with correct orientation and applied settings (flash, zoom).  

## ✅ Pass Criteria  
- Photo capture works without issues.  
- No freezes, black screens, or crashes.  
- Photo file is saved and viewable in the gallery.  

## 📎 Notes  
- This general case validates only the **core photo capture workflow**.  
- The following **specific use cases** extend and validate particular functionalities:  

  - UC_Photo_01_TakeFrontCameraPhoto.md  
  - UC_Photo_02_TakeFrontCameraPhotoFlashOff.md  
  - UC_Photo_03_TakeFrontCameraPhotoFlashOn.md  
  - UC_Photo_04_TakeFrontCameraPhotoWithZoom.md  
  - UC_Photo_05_TakeFrontCameraPhotoMultipleOrientations.md  
    - UC_Photo_5A_TakeFrontCameraPhotoPortrait.md  
    - UC_Photo_5B_TakeFrontCameraPhotoLandscapeLeft.md  
    - UC_Photo_5C_TakeFrontCameraPhotoLandscapeRight.md  
  - UC_Photo_06_TakeFrontCameraPhotoDuringCall.md  
  - UC_Photo_07_TakeFrontCameraPhotoNotification.md  
  - UC_Photo_08_TakeFrontCameraPhotoMultipleResolutions.md  
    - UC_Photo_8A_TakeFrontCameraPhotoHD.md  
    - UC_Photo_8B_TakeFrontCameraPhotoFHD.md  
    - UC_Photo_8C_TakeFrontCameraPhotoSD.md  
  - UC_Photo_09_FrontCamera_OrientationLocked.md
