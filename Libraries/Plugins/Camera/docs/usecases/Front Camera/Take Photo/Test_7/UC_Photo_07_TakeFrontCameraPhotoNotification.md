# 🎥 Use Case: Take Photo with Front Camera While Receiving a Notification  

## 🎯 Objective  
Validate that a photo can be captured with the **front camera** while receiving a notification, without affecting photo capture or UI.  

## 🧪 Test Scope  
- **Included:**  
  - Capturing a photo while a system notification appears.  
- **Excluded:**  
  - Zoom, flash, orientation changes, active call.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device is able to receive notifications.  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Switch Camera Button**: visible. 

## 🚫 Expected Hidden UI Elements  
- **Resolution Selector**: optional before capture.  

## ✋ Interaction Rules  
- **Capture Button** → Tap → Take photo while notification appears.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Trigger a system notification (e.g., message, app alert).  
3. Tap **Capture Button** while the notification is displayed. 

### ✅ Expected Result  
- Photo is captured successfully despite notification overlay.  
- Image appears in gallery.  
- Camera UI remains responsive, no crashes occur.  

## ✅ Pass Criteria  
- Captured photo is saved correctly.  
- Camera UI handles notification without disruption.  

## 📎 Notes  
- Validate notification behavior across different types (banner, alert, lock screen). 
