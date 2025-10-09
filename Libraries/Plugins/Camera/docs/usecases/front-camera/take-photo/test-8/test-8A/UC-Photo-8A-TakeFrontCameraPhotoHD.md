# 🎥 Use Case: Take Photo with Front Camera in HD Resolution  

## 🎯 Objective  
Validate that front camera photo is captured correctly in **HD** resolution.  

## 🧪 Test Scope  
- **Included:** Capture photo in HD resolution.  
- **Excluded:** Zoom, flash, orientation changes, notifications, active call.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Front camera selected, device supports HD resolution.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Resolution Selector**: visible, allows selection of HD, FHD, or SD.  
- **Switch Camera Button**: visible.

## ✋ Interaction Rules  
- **Resolution Selector** → Select desired resolution before capture.  
- **Capture Button** → Tap → Take photo in the selected resolution.  

## 📸 Test Steps  
1. Select HD resolution.  
2. Tap **Capture Button**.  

### ✅ Expected Result  
- Photo is captured in HD resolution correctly.  

## ✅ Pass Criteria 
- Camera UI remains responsive.