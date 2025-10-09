# 📷 Use Case: Take Photo with Rear Camera (General)

## 🎯 Objective
Verify that the user can take photos using the **rear camera**. This general use case serves as an overview, while specific functionalities such as flash, zoom, orientation, active calls, notifications, and resolution are covered in dedicated use cases.

## 🧪 Test Scope
- **Included:**  
  - Taking photos using the rear camera.
  - Validating basic capture functionality with shutter sound.
  - Referencing specific functionalities handled in separate use cases.  

- **Excluded:**  
  - Front camera photo capture (covered in other use cases).  
  - Complex UI interactions beyond the capture process (covered in specific cases).  

## 📝 Preconditions
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has **camera permissions** enabled.  
- Rear camera is available and functional.  

## ✅ Expected Visible UI Elements
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible and configurable.  
- **Camera Preview**: showing rear camera view.  

## 🚫 Expected Hidden UI Elements
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while capturing a photo.  
- **Resolution Selector**: disabled until a capture option is selected.  
- **Close (X) Button**: disabled during capture.  

## ✋ Interaction Rules
- **Take Photo Button**
  - Tap → photo is captured and saved.
  - Shutter sound plays on capture.

- **Flash Toggle**
  - Can be enabled or disabled depending on test scenario (handled in specific use cases).

- **Zoom / Orientation / Resolution / Notifications / Active Call**
  - These behaviors are tested in separate, specific use cases.

## 📸 Specific Use Cases
The following specific use cases cover additional functionalities and scenarios for rear camera photo capture:

- **UC_Photo_01_TakePhotoRearCamera**  
- **UC_Photo_02_TakePhotoWithFlashOff**  
- **UC_Photo_03_TakePhotoWithFlashOn**  
- **UC_Photo_04_TakePhotoWithZoom**  
- **UC_Photo_05_TakePhotoUnlockedOrientation**  
  - UC_Photo_05A_TakePhotoPortrait  
  - UC_Photo_05B_TakePhotoLandscapeLeft  
  - UC_Photo_05C_TakePhotoLandscapeRight  
- **UC_Photo_06_TakePhotoDuringActiveCall**  
- **UC_Photo_07_TakePhotoWhileReceivingNotification**  
- **UC_Photo_08_TakePhotoDifferentResolutions**  
  - UC_Photo_08A_TakePhoto_HDResolution  
  - UC_Photo_08B_TakePhoto_FHDResolution  
  - UC_Photo_08C_TakePhoto_SDResolution  
- **UC_Photo_09_LockedOrientation**  

### ✅ Expected Result
- User can successfully capture photos using the rear camera.  
- Shutter sound plays for each capture.  
- Photos are saved correctly without errors or distortion.  

### ✅ Pass Criteria
- Photo is captured and saved correctly.  
- UI elements behave as expected during capture.  
- No crashes or freezes occur.  

### 📎 Notes
- All advanced behaviors (flash, zoom, orientation, resolutions, notifications, and active calls) are tested in dedicated specific use cases.  
- This general use case serves as a baseline for validating the rear camera’s basic photo capture functionality.
