# 🎥 Use Case: Take Photo with Front Camera in Landscape-Left Orientation  

## 🎯 Objective  
Validate that front camera photo is captured correctly in **landscape-left** orientation.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing photo in landscape-left orientation.  
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
- **Capture Button** → Tap → Take photo in landscape-left orientation.  

## 📸 Test Steps  
1. Rotate device to **landscape-left**.  
2. Tap **Capture Button**.

### ✅ Expected Result  
- Photo is captured in landscape-left orientation and saved.  

## ✅ Pass Criteria  
- Image appears correctly in gallery without rotation issues.  
