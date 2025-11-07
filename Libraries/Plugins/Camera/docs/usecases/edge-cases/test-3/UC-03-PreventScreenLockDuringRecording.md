# 🎥 Use Case: Prevent Screen Lock During Active Recording  

## 🎯 Objective  
Validate that the device screen **remains active** and does **not lock or dim** while a video recording is in progress.  

## 🧪 Test Scope  
- **Included:**  
  - Screen state behavior during video recording.  
  - Validation that auto-lock is disabled while recording is active.  
  - Resume of normal auto-lock behavior once recording stops.  
- **Excluded:**  
  - Flash, zoom, resolution changes, and orientation handling.  
  - App background or interruption recovery (e.g., incoming calls).  
  - Battery or thermal throttling effects.  

## 📝 Preconditions  
- User is authenticated and SDK camera is initialized.  
- **Rear camera** is active and functional.  
- Device **auto-lock** is enabled in system settings (e.g., after 30 seconds).  
- App is in **foreground** and idle before recording starts.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: visible and updating during recording.  

## 🚫 Expected Hidden UI Elements  
- **Screen Lock or Dim Overlay**: must not appear while recording.  
- **Sleep/Wake transition**: should not occur until recording stops.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → start recording, device must stay awake.  
  - Tap again → stop recording, system can resume normal auto-lock behavior.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Ensure device auto-lock is enabled in iOS settings (e.g., 30 seconds).  
3. Tap the **Record button** to start video recording.  
4. Leave the device **idle** for longer than the configured auto-lock period (e.g., 45 seconds).  
   - Observe that the screen remains **on** and **active**.  
5. Tap the **Record button** again to stop recording.  
6. Leave the device idle again.  
   - Verify that the screen now **dims or locks** according to the system’s auto-lock setting.  

### ✅ Expected Result  
- While recording is active, the screen **does not lock, dim, or turn off**.  
- After stopping the recording, **auto-lock resumes** normally.  
- The camera preview remains visible and responsive throughout the test.  

## ✅ Pass Criteria  
- Device remains awake for the entire recording duration.  
- Screen lock behavior returns to normal after recording stops.  
- No interruptions or freezes during recording.  

