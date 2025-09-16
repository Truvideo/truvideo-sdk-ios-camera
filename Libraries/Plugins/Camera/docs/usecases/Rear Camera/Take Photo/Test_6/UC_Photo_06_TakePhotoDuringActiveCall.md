# 📷 Use Case: Take Photo During an Active Call (Rear Camera)  

## 🎯 Objective  
Verify that the user can take a photo using the **rear camera** while the device is on an **active phone call**, ensuring that the camera preview does not freeze and the photo is captured and saved correctly.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera permission**.  
- SDK camera is initialized and active.  
- An **active phone call** is ongoing. 

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible and functional.  
- **Preview**: active and must remain smooth during the call.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: not applicable (photo mode).  
- **Gallery Button**: disabled during capture.  
- **Resolution Selector**: disabled during capture. 

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo must be captured successfully during the call.  
  - Shutter sound must play when the photo is taken.  

- **System Behavior**  
  - The camera preview must **not freeze** or **crash** because of the active call.  
  - The saved photo must be valid and aligned with the device orientation.  

## 📸 Test Steps  
1. Initiate an **active phone or VoIP call** on the device.  
2. Launch the SDK camera.  
3. Switch to **rear camera**.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays. 

### ✅ Expected Result  
- User can take photos normally while on a call.  
- Preview does not freeze.  
- Photos are captured successfully with proper orientation.  
- Shutter sound plays each time a photo is taken.  

### ✅ Pass Criteria  
- No crashes, freezes, or corrupted photos occur.  
- Photos are correctly saved in the gallery.  
- Shutter sound feedback is consistent.  

### 📎 Notes  
- Test with both **short** and **long calls**.  
