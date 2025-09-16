# 🎥 Use Case: Record Video While Receiving a Notification  

## 🎯 Objective  
Verify that video recording continues normally when a **system notification** (SMS, push, email, or alert) is received, ensuring the camera does not freeze, the recording is not interrupted, and the saved file is valid.  

## 🧪 Test Scope  
- **Included:**  
  - Behavior of video recording when a notification arrives.  
  - Camera preview and app stability during the notification.  
  - Video file integrity after recording.  
- **Excluded:**  
  - Notification delivery reliability (OS-level).  
  - Opening, dismissing, or interacting with the notification.  
  - Zoom, pause, flash, or photo capture (covered in other use cases).  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is initialized and active.  
- Device has **camera** and **microphone permissions** granted.  
- Notifications are enabled at OS level.  
- At least one notification will be received during recording.  

## ✅ Expected Visible UI Elements  
- **Record Button**  
  - Visible in idle state.  
  - Starts/stops recording normally, even if a notification is received.  
- **Timer**  
  - Starts when recording begins.  
  - Must remain responsive and not freeze during the notification.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Must function as expected regardless of incoming notifications.  
- **System Behavior**  
  - Notification banner/alert may appear, but must not freeze preview or interrupt recording. 

## 📸 Test Steps  
1. Enable notifications (e.g., SMS, push, email) on the device.  
2. Launch the SDK camera.  
3. Switch to **front or rear camera**.  
4. Tap **Record button** to start recording.  
   - Verify the timer starts.  
   - Verify preview is smooth.  
5. Trigger an **incoming notification** (e.g., send a message to the device).  
   - Verify the notification is displayed.  
   - Verify recording continues without freezing. 

## ✅ Expected Result  
- Recording continues normally during a notification.  
- No crashes, freezes, or interruptions occur.  

## 📎 Notes  
- Test with multiple notification types (SMS, push, system alerts).  
- Validate in both **portrait** and **landscape** orientations.  
