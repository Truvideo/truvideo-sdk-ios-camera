# 🎥 Use Case: Take Photo with Front Camera and Flash Enabled  

## 🎯 Objective  
Validate that a photo can be captured with the **front camera** while the flash is **enabled**, and the flash effect is applied.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera photo capture with flash enabled.  
- **Excluded:**  
  - Zoom, orientation changes, active call, notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Flash is enabled for the front camera.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Flash Control**: visible and set to ON.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo with flash.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Enable flash.  
3. Tap **Capture Button**. 

### ✅ Expected Result  
- Photo is captured successfully with flash illumination.  
- Image is saved in the gallery.  

## ✅ Pass Criteria  
- Photo shows visible flash effect.  
- Camera UI remains responsive and no crashes occur.  
