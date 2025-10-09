# 🎥 Use Case: Take Photo with Front Camera  

## 🎯 Objective  
Validate that tapping the **Capture button** on the **front camera** successfully takes a photo.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a photo using the front camera.  
- **Excluded:**
  - Flash, zoom, orientation changes.  
  - Notifications, active call, or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements
- **Capture Button**: visible and enabled.  
- **Gallery Button**: visible in idle state.  
- **Zoom Control / Pinch**: visible if supported.  

## 🚫 Expected Hidden UI Elements  
- **Flash Control**: hidden until activated (if any).  
- **Resolution Selector**: optional and visible before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take a photo.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Tap **Capture Button**.  

### ✅ Expected Result  
- Photo is taken successfully with the front camera.  
- Image appears in the gallery.  
- No crashes or UI issues occur.  

## ✅ Pass Criteria  
- Photo is saved and visible in gallery.  
- Camera UI remains responsive. 
