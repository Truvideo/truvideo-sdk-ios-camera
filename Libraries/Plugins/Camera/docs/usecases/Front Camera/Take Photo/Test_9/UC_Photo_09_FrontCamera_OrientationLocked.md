# 📷 Use Case: Take Photo with Device Orientation Locked (Front Camera)  

## 🎯 Objective  
Verify that the user can take a photo with the **front camera** while the **device orientation is locked**, ensuring that the captured photo remains in **Portrait orientation** even if the device is physically rotated, while UI icons may rotate according to device rotation.  

## 📝 Preconditions  
- SDK camera is installed, initialized, and launched.  
- Device has **camera permission** enabled.  
- Device orientation is **locked by the user to Portrait**.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Switch Camera Button**: visible.  
- **Gallery Button**: visible.  
- **Preview**: remains in Portrait orientation regardless of device rotation.  

## 🚫 Expected Hidden UI Elements  
- **Resolution Selector**: optional before capture.  

## 📸 Test Steps  
1. Launch the **SDK camera**.  
2. Switch to **front camera**.  
3. Ensure the **device orientation is locked to Portrait** by the user.  
   - Verify that the camera preview remains in **Portrait**, even if the device is physically rotated.  
4. Physically rotate the device to **Landscape Left** and **Landscape Right**.  
   - Verify that **UI icons** (shutter, switch camera, gallery, zoom) rotate according to the device orientation.  
   - Verify that **camera preview** remains in **Portrait**.  
5. Tap the **Take Photo Button**.  

### ✅ Expected Result  
- Photo is saved correctly in **Portrait orientation**.  
- Shutter sound plays on capture.  
- Camera preview remains locked in Portrait, even if device is rotated.  
- UI icons rotate according to physical device orientation.  

### ✅ Pass Criteria  
- Photo orientation is always Portrait.  
- UI icons respond to device rotation.  
- Shutter sound plays reliably on each capture.  

### 📎 Notes  
- Test with multiple device rotations while orientation is locked.  
