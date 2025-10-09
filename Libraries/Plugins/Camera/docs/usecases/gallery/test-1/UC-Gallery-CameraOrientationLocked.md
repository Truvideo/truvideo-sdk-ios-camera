## 📱 Use Case: Camera and Gallery Orientation Behavior (Device Orientation Locked)

### 🎯 Objective
Verify that when the **device orientation is locked**, the SDK camera preview and gallery media visualization remain **fixed in Portrait**, while all **UI icons** dynamically rotate according to the physical orientation of the device.

### 🧪 Test Scope
This test covers:  
- Camera preview orientation when the device orientation is **locked**.  
- UI icons rotation (Close button, capture controls, flash, zoom, resolution selector, timer).  
- Gallery view orientation (thumbnails, media navigation, and visualization) when orientation is locked.  
- Media playback orientation (photo/video visualizer inside the SDK).  

It does not cover:  
- Behavior when the orientation lock is **disabled** (covered in a separate use case).  

### 📝 Preconditions
- The user is authenticated with valid data.  
- The app has camera, microphone, and storage permissions granted.  
- The SDK camera is initialized and active.  
- **Device orientation lock is enabled (Portrait mode enforced).**  
- At least one photo or video exists in the gallery.  

### ✅ Expected Visible UI Elements
**Camera View (Content):**  
- **Camera Preview** → always fixed in **Portrait** regardless of device rotation.  

**Camera View (UI Controls):**  
- **Close (X) Button** → rotates according to device orientation.  
- **Photo/Video Capture Button** → rotates with device orientation.  
- **Resolution Selector** → rotates correctly.  
- **Flash Toggle** → rotates correctly.  
- **Zoom Control** → rotates correctly.  
- **Timer** → rotates correctly.  

**Gallery View:**  
- **Media Visualization (photo/video)** → always fixed in **Portrait**.  
- **Gallery Controls (Close, Delete, Next/Previous, etc.)** → rotate dynamically according to device orientation.  

### 🚫 Expected Hidden UI Elements
- None specific to this test.  

### ✋ Interaction Rules
- Camera preview must remain **Portrait-only** when orientation is locked.  
- Gallery media visualization must remain **Portrait-only** when orientation is locked.  
- UI icons must **always rotate** according to the physical orientation of the device.  
- Camera and gallery functionality (capture, delete, zoom, playback) must remain fully operational.  

### 📸 Test Steps
1. Enable **device orientation lock** (Portrait).  
2. Launch the SDK camera.  
3. Hold the device in **Portrait**.  
   - Verify camera preview is in Portrait.  
   - Verify all icons (X, flash, capture, zoom, resolution, timer) are aligned correctly.  
4. Rotate the device to **Landscape Left**.  
   - Verify camera preview stays Portrait.  
   - Verify all icons rotate correctly with the device.  
5. Rotate the device to **Landscape Right**.  
   - Verify camera preview stays Portrait.  
   - Verify all icons rotate correctly.  
6. Capture a photo or video.  
7. Open the **Gallery** and view the captured media.  
   - Verify media visualization remains Portrait regardless of rotation.  
   - Verify gallery controls (Close, Delete) rotate correctly.  

### 🎬 Expected Result
- Camera preview and gallery media visualization remain **locked in Portrait**.  
- UI icons rotate dynamically with the physical device orientation.  
- No freezes, distortions, or misaligned icons occur.  
- Camera and gallery remain fully functional.  

### ✅ Pass Criteria
- Camera preview is always **Portrait**.  
- Gallery media visualization is always **Portrait**.  
- All UI icons rotate correctly when device is rotated.  
- No crashes, freezes, or UI misalignments occur.  

### 📎 Notes
- Validate with both **front and rear cameras**.  
- Test with photos and videos in the gallery.  
- Run on multiple device types (phones and tablets).  
