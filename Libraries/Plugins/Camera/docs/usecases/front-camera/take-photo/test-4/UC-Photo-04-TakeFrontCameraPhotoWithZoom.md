# 🎥 Use Case: Take Photo with Front Camera and Adjust Zoom  

## 🎯 Objective  
Validate that a photo can be captured with the **front camera** while adjusting the **zoom level** during capture.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera photo capture with adjustable zoom.  
- **Excluded:**  
  - Flash, orientation changes, active call, notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Zoom control (pinch or slider) is available and functional.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Zoom Control / Pinch Gesture**: visible and interactive.  
- **Switch Camera Button**: visible.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements 
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo.  
- **Zoom Control** → Adjust zoom level before or during capture.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Adjust zoom using the **zoom control** (pinch or slider).  
3. Tap **Capture Button** while at the selected zoom level.  
4. Verify that the photo is captured correctly with the applied zoom. 

### ✅ Expected Result  
- Photo is captured successfully with the selected zoom level.  
- No UI glitches or crashes occur.  

## ✅ Pass Criteria  
- Captured photo reflects the adjusted zoom level.  
- Camera UI remains responsive throughout the interaction.  

## 📎 Notes  
- Confirm smooth pinch/slider response across different devices.
