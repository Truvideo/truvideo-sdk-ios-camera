# 🎥 Use Case: Take Photo with Front Camera and Flash Disabled  

## 🎯 Objective  
Validate that a photo can be captured with the **front camera** while the flash is **disabled**, and no flash effect is applied.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera photo capture with flash disabled.  
- **Excluded:**  
  - Zoom, orientation changes, active call, notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Flash is disabled or unavailable for the front camera.  

## ✅ Expected Visible UI Elements
- Capture Button: visible and enabled.
- Switch Camera Button: visible (can switch to rear camera if needed).
- Gallery Button: visible in idle state.

## 🚫 Expected Hidden UI Elements  
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo without flash.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Ensure flash is **disabled**.  
3. Tap **Capture Button**.

### ✅ Expected Result  
- Photo is captured successfully without flash illumination.  
- Image is saved in the gallery.  

## ✅ Pass Criteria  
- Photo matches scene lighting without flash.  
- Camera UI remains responsive and no crashes occur.  

## 📎 Notes  
- Confirm flash button is hidden or disabled for front camera devices.
