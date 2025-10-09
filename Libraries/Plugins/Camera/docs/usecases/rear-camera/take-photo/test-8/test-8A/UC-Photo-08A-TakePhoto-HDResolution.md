# 📷 Use Case: Take Photo in HD Resolution (Rear Camera)  

## 🎯 Objective  
Verify that the user can take a photo with the **rear camera** in **HD resolution**, ensuring the image is saved with the correct resolution.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera permission**.  
- SDK camera is initialized and active. 
- **HD resolution** is available in the Resolution Selector.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Resolution Selector**: visible with **HD option** selected.  
- **Flash Toggle**: visible and functional.  
- **Preview**: adapts to HD resolution.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: not applicable (photo mode).  
- **Gallery Button**: disabled during capture.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Select **HD resolution** from the Resolution Selector.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.  
   - Verify photo is saved in **HD resolution**.  

### ✅ Expected Result  
- Photo is saved correctly in **HD resolution**.  
- Shutter sound plays on capture.  
- No distortion or scaling issues.  
