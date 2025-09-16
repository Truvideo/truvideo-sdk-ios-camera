# 🎥 Use Case: Record Video While Receiving a Notification with Front Camera  

## 🎯 Objective  
Validate that front camera video recording behaves correctly when the user receives a notification during recording.  

## 🧪 Test Scope  
- **Included:**  
  - Front camera video recording during incoming notifications (system or app).  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
  - Pausing/resuming recording.  
  - Active call scenarios.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device can receive notifications during recording.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled before recording.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera while recording video.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- Video recording should continue or pause based on notification handling rules of the OS.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. Tap **Record Button** to start recording.  
3. Generate a notification (system or app) during recording.  
4. Observe whether recording continues or pauses. 

### ✅ Expected Result  
- Video recording continues or handles the notification gracefully.  
- Video is saved without corruption.  
- App does not crash or freeze.  

## ✅ Pass Criteria  
- Recording behaves according to OS rules during notifications.  
- Video file is intact and playable.  

## 📎 Notes  
- Test with multiple types of notifications: banners, alerts, and push notifications.
