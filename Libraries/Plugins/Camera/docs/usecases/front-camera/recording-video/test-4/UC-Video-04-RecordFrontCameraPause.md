# 🎥 Use Case: Record Video and Pause with Front Camera  

## 🎯 Objective  
Validate that tapping the **Pause button** during front camera recording pauses the video correctly.  

## 🧪 Test Scope  
- **Included:**  
  - Pausing video recording.  
  - Timer stops when paused.  
- **Excluded:**  
  - Resuming recording.  
  - Flash, zoom, orientation changes.  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled before recording.  
- **Pause Button**: visible during recording.  
- **Timer**: visible and counting during recording. 

## 🚫 Expected Hidden UI Elements  
- **Resume Button**: hidden until paused.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- **Pause Button** → Tap → Recording pauses, timer stops.  

## 📸 Test Steps  
1. Launch SDK camera and select **front camera**.  
2. Tap **Record Button** to start recording.  
3. Tap **Pause Button** during recording.  
   - Verify recording stops.  
   - Timer stops counting.  
4. Ensure UI reflects paused state.  

### ✅ Expected Result  
- Video recording pauses successfully.  
- Timer stops incrementing.  
- No crashes or UI glitches occur.  

## ✅ Pass Criteria  
- Video can be paused successfully.  
- UI reflects paused state accurately. 
