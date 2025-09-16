# 🎥 Use Case: Take Photo with Front Camera in Multiple Device Orientations  

## 🎯 Objective  
Validate that front camera photos can be captured correctly in different device orientations when orientation is **not locked**.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing photos in multiple orientations: portrait, landscape-left, landscape-right.  
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
- **Capture Button** → Tap → Take photo in current orientation.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. For each orientation (portrait, landscape-left, landscape-right):  
   - Position the device in the desired orientation.  
   - Tap **Capture Button**.  

### ✅ Expected Result  
- Photos are captured correctly in all orientations.  
- Images appear in gallery with correct orientation.  

## ✅ Pass Criteria  
- Captured photos reflect the actual device orientation.  
- No UI glitches or crashes occur.  

## 📎 Notes  
- Orientation metadata should be consistent across devices and OS versions.
