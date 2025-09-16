# 📷 Use Case: Take Photo in Landscape Left Orientation (Rear Camera)  

## 🎯 Objective  
Verify that the user can take a photo with the **rear camera** while the device is in **Landscape Left orientation**, ensuring the captured photo is aligned correctly.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has camera permission granted.  
- SDK camera is initialized and active.  
- Device orientation lock is **disabled**.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible but not required for this test.  
- **Preview**: adapts to Landscape Left orientation.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while in preview.  
- **Resolution Selector**: not available during capture. 

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Rotate the device to **Landscape Left orientation**.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.  
   - Verify photo is saved in Landscape Left orientation.  

### ✅ Expected Result  
- Photo is saved correctly in **Landscape Left orientation**.  
- Shutter sound plays on capture.  
- No distortion or incorrect rotation.  
