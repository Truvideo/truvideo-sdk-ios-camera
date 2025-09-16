# 🎥 Use Case: Pause Video Recording with Rear Camera  

## 🎯 Objective  
Validate that tapping the **Pause button** during an active recording correctly **pauses the video recording**, ensuring recording does not continue until explicitly resumed.  

## 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording.  
  - Pause functionality.  
  - Timer behavior when paused.  
- **Excluded:**  
  - Resume or Stop actions after pause.  
  - Flash or audio configurations.  
  - Background/foreground transitions.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera and microphone permissions**.  
- **Rear camera** is selected.  

## ✅ Expected Visible UI Elements  
- **Record Button**: visible and enabled in idle state.  
- **Pause Button**: visible only when recording is active.  
- **Timer**: counts recording duration until paused.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording begins.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap once → recording starts.  
- **Pause Button**  
  - Tap → recording pauses.  
  - Timer stops counting.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Tap the **Record button** to start recording.  
   - Verify timer starts counting.  
   - Verify recording indicator is active.  
4. Tap the **Pause button**.  
   - Verify recording pauses immediately.  
   - Verify timer stops counting.  
   - Verify preview remains visible but not recording.  

### ✅ Expected Result  
- Video recording starts correctly when Record is pressed.  
- Recording pauses immediately when Pause is pressed.  
- Timer stops counting during pause.  

## ✅ Pass Criteria  
- Recording halts correctly on pause.  
- Timer reflects paused state.  
- No crashes, freezes, or unexpected resume behavior.  

## 📎 Notes  
- Test both **short** and **long recordings** before pausing.  
- Validate UI consistency (Pause button visible only during active recording).  
