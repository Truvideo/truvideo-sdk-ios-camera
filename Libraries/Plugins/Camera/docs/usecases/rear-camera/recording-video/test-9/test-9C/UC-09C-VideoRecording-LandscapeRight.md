# 🎥 Use Case: Video Recording - Landscape Right Orientation  

## 🎯 Objective  
Verify that video recording works correctly in **landscape right orientation** when the device orientation is unlocked.  

## 🧪 Test Scope  
- **Included:**  
  - Recording video in landscape right orientation.  
  - Alignment of camera preview and UI elements.  
- **Excluded:**  
  - Other orientations (portrait, landscape left).  
  - Front camera recording.  

## 📝 Preconditions  
- Device orientation is **unlocked**.  
- Camera and microphone permissions are granted.  
- SDK camera is launched with **rear camera active**.  

## ✅ Expected Visible UI Elements  
- **Record Button** (enabled).  
- **Zoom Control** (adjustable).  
- **Flash Toggle** (ON/OFF depending on user setting).  
- **Timer** (starts when recording begins).  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: hidden until recording starts.  
- **Gallery Button**: disabled while recording is active.  
- **Resolution Selector**: disabled once recording starts.  
- **Close (X) Button**: disabled once recording starts.  

## ✋ Interaction Rules  
- **Record Button**  
  - Tap → start recording in landscape right orientation.  
- **Zoom Control**  
  - Adjust zoom while recording → preview updates smoothly.  

## 📸 Test Steps  
1. Unlock device orientation.  
2. Launch the SDK camera → ensure rear camera is active.  
3. Hold device in **landscape right orientation**.  
4. Tap the **Record button** to start recording.  
   - Verify preview is displayed in landscape right.  
   - Verify timer starts counting.  
5. Adjust zoom during recording.  
   - Verify preview remains smooth in landscape right. 

### ✅ Expected Result  
- Video is recorded and saved correctly in **landscape right orientation**.  
- UI elements remain aligned in landscape right throughout recording.  

## ✅ Pass Criteria  
- Recording starts/stops successfully.  
- Preview and icons remain stable in landscape right.  
- Video playback shows correct landscape right orientation.  
