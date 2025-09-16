# 🎥 Use Case: Record Video with Front Camera and Flash Disabled  

## 🎯 Objective  
Validate that tapping the **Record button** on the **front camera** records video correctly without using flash. (Front camera flash is not supported during video recording.)  

## 🧪 Test Scope  
- **Included:**  
  - Front camera video recording with flash disabled.  
- **Excluded:**  
  - Audio, zoom, orientation changes.  
  - Pausing or resuming recording.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- **Flash is not supported** for front camera video recording.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Timer**: default **00:00:00**, visible before recording.  
- **Gallery Button**: visible in idle state.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Flash Control**: hidden/unavailable for front camera.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → recording starts.  
  - Timer starts counting.  
  - Flash is not applied.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **front camera**.  
3. Verify flash is not supported.  
4. Tap the **Record button**.  
   - Verify recording starts, timer increments. 

### ✅ Expected Result  
- Video records correctly without flash illumination.  
- No crashes or UI issues occur.  

## ✅ Pass Criteria  
- Video is saved successfully.  
- Flash is not applied during recording.  

## 📎 Notes  
- Confirm flash button is disabled for front camera devices.
