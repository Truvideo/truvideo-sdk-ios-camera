# 🎥 Use Case: Record Video, Pause and Resume with Front Camera  

## 🎯 Objective  
Validate that a front camera video can be paused and resumed correctly.  

## 🧪 Test Scope  
- **Included:**  
  - Pausing and resuming video recording.  
  - Timer stops while paused and resumes correctly.  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
- **Excluded:**  
  - Notifications or background behavior.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible before recording.  
- **Pause Button**: visible during recording.  
- **Resume Button**: visible after pausing.  
- **Timer**: visible and counting while recording.  

## 🚫 Expected Hidden UI Elements  
- **Resume Button**: hidden until paused.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled while recording is active.  

## ✋ Interaction Rules  
- **Record Button** → Tap → Start recording.  
- **Pause Button** → Tap → Pause recording; timer stops.  
- **Resume Button** → Tap → Resume recording; timer continues.  

## 📸 Test Steps  
1. Launch SDK camera and select **front camera**.  
2. Tap **Record Button** to start recording.  
3. Tap **Pause Button**.  
   - Verify recording stops and timer stops.  
4. Tap **Resume Button**.  
   - Verify recording continues and timer resumes.  
5. Tap **Stop Button** to finish recording.  
6. Play video to verify continuous recording.  

### ✅ Expected Result  
- Video pauses and resumes correctly without losing content.  
- Timer reflects paused and resumed states accurately.  

## ✅ Pass Criteria  
- Paused and resumed recording is seamless.  
- Video playback includes all recorded segments.  
- No UI glitches or crashes occur.  
