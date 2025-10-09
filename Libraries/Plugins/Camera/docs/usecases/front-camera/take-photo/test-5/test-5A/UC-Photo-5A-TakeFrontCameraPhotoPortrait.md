# 🎥 Use Case: Take Photo with Front Camera in Portrait Orientation  

## 🎯 Objective  
Validate that front camera photo is captured correctly in **portrait** orientation.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing photo in portrait orientation.  
- **Excluded:**  
  - Flash, zoom, active call, notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device orientation is **unlocked**. 

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Switch Camera Button**: visible. 

## 🚫 Expected Hidden UI Elements  
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo in portrait orientation.  

## 📸 Test Steps  
1. Position device in **portrait**.  
2. Tap **Capture Button**. 

### ✅ Expected Result  
- Photo is captured in portrait orientation and saved.  

## ✅ Pass Criteria  
- Image appears correctly in gallery without rotation issues. 