## 📷 Use Case: Video Recording with Flash During Background Transition  

### 🎯 Objective  
Validate that when recording a video using the **rear camera with flash enabled**, the system properly manages **flash and recording states** when the app transitions between **foreground and background**. Specifically:  
- Flash must turn **off automatically** when app is backgrounded.  
- Recording must be **paused automatically** during backgrounding.  
- On returning to foreground, flash must **remain OFF** and recording must stay in a **paused state** until explicitly resumed by the user.  
- Flash must only re-enable when the user **resumes recording**.  

### 🧪 Test Scope  
- **Included:**  
  - Rear camera video recording with flash enabled.  
  - Flash state transitions when backgrounding/foregrounding the app.  
  - Automatic pause and manual resume of recording.  

- **Excluded:**  
  - Front camera (no flash support).  
  - External flash hardware or third-party flashlight apps.  
  - App relaunch after force-close or system kill.  

### 📝 Preconditions  
- User is authenticated successfully.  
- SDK camera is launched with **rear camera active**.  
- **Camera, microphone, and storage permissions** granted.  
- Flash toggle is set to **ON** before recording begins.  
- App is in **foreground** state.  

### ✅ Expected Visible UI Elements  
- **Record Button**: visible, enabled.  
- **Flash Toggle**: visible, set to **ON** before recording.  
- **Timer**: starts at 00:00 when recording begins.  
- **Stop Button**: replaces record button after recording starts.  
- **Resume Button**: visible only when recording is paused.  
- **Gallery Button**: visible but disabled during recording.  

### 🚫 Expected Hidden/Disabled UI Elements  
- **Resolution Selector**: disabled during recording.  
- **Zoom Control**: frozen during background state.  
- **Flash Toggle**: inaccessible while app is backgrounded.  
- **Pause Button**: not used (pause is automatic in this case).  

### ✋ Interaction Rules  
- **Record Start**:  
  - Tap Record → recording starts, flash turns ON, timer starts counting.  
- **Background Transition**:  
  - App sent to background →  
    - Flash turns OFF instantly.  
    - Recording pauses automatically.  
    - Timer stops.  
- **Foreground Return**:  
  - App returns to foreground →  
    - Camera preview reloads.  
    - Recording remains paused.  
    - Flash re-enables automatically in ON state.  
- **Resume Action**:  
  - Tap Resume → recording continues with flash ON.  
  - Timer resumes counting.  

### 📸 Test Steps  
1. Open the SDK camera.  
2. Ensure **rear camera** is active and **flash is set to ON**.  
3. Tap **Record button**.  
   - Verify timer starts at 00:00.  
   - Verify flash illuminates continuously.  
4. Send the app to **background** (e.g., press Home or swipe up).  
   - Verify flash turns OFF immediately.  
   - Verify recording is paused (timer frozen).  
5. Return to **foreground**.  
   - Verify camera preview reloads correctly.  
   - Verify flash re-enables automatically in ON mode.  
   - Verify recording remains **paused** (timer not counting).  
6. Tap **Resume button**.  
   - Verify flash is ON again.  
   - Verify timer resumes counting.  
   - Verify video continues recording smoothly.  

### ✅ Expected Result  
- Flash always turns **OFF** when backgrounding.  
- Recording always **pauses automatically** in background.  
- On foreground return, flash is **re-enabled automatically** and recording remains paused.  
- User can resume recording with flash ON.  
- Final video playback is smooth, continuous, and uncorrupted.  

### ✅ Pass Criteria  
- Flash OFF during background, flash ON after resume.  
- Recording pause/resume works without user error.  
- Video file contains all valid frames.  
- No crashes, freezes, or UI misalignments during transitions.  

### 📎 Notes  
- Test with **short (1–2 sec)** and **long (30+ sec)** background intervals.  
- Validate behavior in both **portrait** and **landscape orientations**.  
- Verify behavior with **low battery** or **screen lock** triggered during recording.  
- Confirm that flash state remains consistent even if device has **auto-brightness** or **battery saver** enabled.  
