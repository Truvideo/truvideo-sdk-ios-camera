# 🎥 Use Case: Take Photo with Front Camera During an Active Call  

## 🎯 Objective  
Validate that a photo can be captured with the **front camera** while a phone call is active, without affecting photo capture or UI.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a photo during an active call.  
- **Excluded:**  
  - Zoom, flash, orientation changes, notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Active phone call is in progress.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Switch Camera Button**: visible. 

## 🚫 Expected Hidden UI Elements 
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo during active call.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Ensure a phone call is active.  
3. Tap **Capture Button**. 

### ✅ Expected Result  
- Photo is captured successfully without interference from the call.  
- Image appears in gallery.  
- No UI glitches, crashes, or dropped call issues occur.  

## ✅ Pass Criteria  
- Captured photo is saved correctly.  
- Camera UI remains responsive.  

## 📎 Notes  
- Test with both video and audio calls if possible. 
