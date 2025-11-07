# 🎥 Use Case: Flash State Consistency Across Cameras and Recording  

## 🎯 Objective  
Validate that the **flash state** behaves consistently when switching between cameras and during active video recordings. The flash must automatically disable in invalid contexts (e.g., front camera or while recording).  

## 🧪 Test Scope  
- **Included:**  
  - Flash toggle behavior between **rear** and **front** cameras.  
  - Auto-disable of flash during video recording.  
  - Flash state consistency after switching cameras or stopping recordings.  
- **Excluded:**  
  - Flash behavior in **photo mode**.  
  - Torch (continuous light) functionality.  
  - Hardware flash emission validation.  

## 📝 Preconditions  
- SDK Camera is initialized and displayed.  
- Device camera permissions are granted.  
- Both **rear** and **front** cameras are available and functional.  
- Recording is idle (no active session).  

## ✅ Expected Visible UI Elements  
- **Flash Button**: visible and tappable.  
- **Record Button**: visible and enabled.  
- **Timer**: visible, showing default `"00:00:00"`.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording starts.  
- **Gallery Button**: disabled during active recording.  
- **Resolution Selector**: disabled while recording.  

## ✋ Interaction Rules  
- **Flash Button**  
  - Tapping it toggles the flash state on the **rear camera** only.  
- **Switch Camera Button**  
  - When switching to the **front camera**, flash should reset (no active state).  
- **Record Button**  
  - Starting recording should **automatically disable** the flash.  
  - Stopping recording should **keep flash off**.  

## 📸 Test Steps  
1. Start in **rear camera** mode.  
   - Flash label shows `"Flash Off"`.  
2. Tap **Flash Button** to enable flash.  
   - Flash label updates to `"Flash On"`.  
3. Tap **Switch Camera Button** to switch to the **front camera**.  
   - Flash resets (label shows `"Flash"`).  
4. Tap **Record Button** to start recording.  
   - Flash automatically turns off (`"Flash Off"`).  
   - Timer starts incrementing.  
5. Tap **Record Button** again to stop recording.  
   - Flash remains `"Flash Off"`.  
6. Tap **Switch Camera Button** to return to the **rear camera**.  
7. Start a new recording.  
   - Flash remains `"Flash Off"` while recording.  
   - Timer increments from `"00:00:00"`.  
8. Stop recording.  

### ✅ Expected Result  
- Flash is automatically disabled whenever recording starts.  
- Switching to the **front camera** resets any previous flash state.  
- Flash remains off after recordings stop or when switching back to the **rear camera**.  
- Timer behaves correctly during all recordings.  
- No UI glitches, black screens, or crashes occur.  

## ✅ Pass Criteria  
- Flash label equals `"Flash Off"` whenever a recording is in progress or after completion.  
- Flash resets to `"Flash"` after switching to the **front camera**.  
- Timer increments correctly while recording.  
- All state transitions occur without UI errors or inconsistencies.  

## 📎 Notes  
- Validate behavior in both **portrait** and **landscape** orientations.  
- This is a **special edge case** test ensuring flash logic remains synchronized with camera state.  
- Recommended to re-run after changes in **camera session** or **torch management logic**.  
