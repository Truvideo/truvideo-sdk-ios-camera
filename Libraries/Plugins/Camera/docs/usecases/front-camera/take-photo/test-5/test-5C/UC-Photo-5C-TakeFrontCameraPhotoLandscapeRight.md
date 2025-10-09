# 🎥 Use Case: Take Photo with Front Camera in Landscape-Right Orientation  

## 🎯 Objective  
Validate that front camera photo is captured correctly in **landscape-right** orientation.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing photo in landscape-right orientation.  
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
- **Capture Button** → Tap → Take photo in landscape-right orientation.  

## 📸 Test Steps  
1. Rotate device to **landscape-right**.  
2. Tap **Capture Button**. 

### ✅ Expected Result  
- Photo is captured in landscape-right orientation and saved.  

## ✅ Pass Criteria  
- Image appears correctly in gallery without rotation issues.  
