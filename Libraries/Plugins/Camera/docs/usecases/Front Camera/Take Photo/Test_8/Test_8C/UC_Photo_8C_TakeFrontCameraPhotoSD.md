# 🎥 Use Case: Take Photo with Front Camera in SD Resolution  

## 🎯 Objective  
Validate that front camera photo is captured correctly in **SD** resolution.  

## 🧪 Test Scope  
- **Included:** Capture photo in SD resolution.  
- **Excluded:** Zoom, flash, orientation changes, notifications, active call.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Front camera selected, device supports SD resolution.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Resolution Selector**: visible, allows selection of HD, FHD, or SD.  
- **Switch Camera Button**: visible.

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo in SD resolution.  

## 📸 Test Steps  
1. Select SD resolution.  
2. Tap **Capture Button**.

### ✅ Expected Result  
- Photo is captured in SD resolution correctly.  

## ✅ Pass Criteria  
- Camera UI remains responsive.
