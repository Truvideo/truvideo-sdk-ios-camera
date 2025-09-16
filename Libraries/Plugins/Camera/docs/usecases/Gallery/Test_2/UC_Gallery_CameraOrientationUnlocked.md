## 📱 Use Case: Camera and Gallery Orientation Behavior (Unlocked Orientation)

### 🎯 Objective
Verify that the SDK camera and gallery adapt correctly to all supported device orientations when orientation lock is disabled, ensuring that the **camera preview, UI icons, and gallery content** rotate properly without distortion, freezing, or misplacement.

### 🧪 Test Scope
This test covers:
- Camera preview orientation.  
- UI icons rotation (Close button, capture controls, flash, zoom, resolution selector, timer).  
- Gallery view orientation (thumbnails, media navigation, and visualization).  
- Media playback orientation (photo/video visualizer inside the SDK).  

It does not cover:
- Orientation lock behavior (covered in a separate test).  

### 📝 Preconditions
- The user is authenticated with valid data.  
- The app has camera, microphone, and storage permissions granted.  
- The SDK camera is initialized and active.  
- Device orientation lock is **disabled**.  
- At least one photo or video exists in the gallery.  

### ✅ Expected Visible UI Elements
**Camera View:**  
- **Close (X) Button** → rotates and remains aligned to the top corner.  
- **Photo/Video Capture Button** → remains centered and functional in all orientations.  
- **Resolution Selector** → rotates and stays aligned properly.  
- **Flash Toggle** → rotates correctly, aligned to its position.  
- **Zoom Control** → adjusts orientation without breaking.  
- **Timer** → rotates and remains visible/functional.  
- **Camera Preview** → rotates smoothly without stretching or cropping errors.  

**Gallery View:**  
- **Gallery Thumbnails** → adapt and rotate correctly in portrait/landscape.  
- **Photo/Video Viewer** → rotates smoothly between orientations.  
- **UI Controls (Next/Previous, Close, Delete, etc.)** → remain aligned to their positions in all orientations.  

### 🚫 Expected Hidden UI Elements
- None specific to this test.  
All standard UI elements (camera + gallery) must remain visible, only rotated accordingly.  

### ✋ Interaction Rules
- Camera must remain fully functional (capture, zoom, flash, timer) in all orientations.  
- Gallery must display media (photo/video) in the correct orientation.  
- UI icons and gallery controls must always match the current device orientation.  

### 📸 Test Steps
1. Launch the SDK camera with orientation lock **disabled**.  
2. Hold the device in **Portrait** mode.  
   - Verify camera preview is upright.  
   - Verify all UI elements (X, flash, zoom, resolution, timer, capture button) are aligned correctly.  
3. Rotate device to **Landscape Left**.  
   - Verify camera preview rotates smoothly.  
   - Verify all UI elements rotate and remain properly positioned.  
4. Rotate device to **Landscape Right**.  
   - Verify camera preview rotates smoothly.  
   - Verify all UI elements rotate and remain properly positioned.  
5. Capture a photo or video, then open the **Gallery**.  
6. In the gallery, rotate the device through **Portrait → Landscape Left → Landscape Right**.  
   - Verify gallery thumbnails adapt properly.  
   - Verify photo/video viewer rotates smoothly.  
   - Verify gallery controls (Close, Delete, Next/Previous) remain correctly positioned.  
7. Return to the camera and confirm orientation continues to work as expected.  

### 🎬 Expected Result
- Camera preview and gallery views rotate correctly in **Portrait**, **Landscape Left**, and **Landscape Right**.  
- All UI elements (camera + gallery) rotate and remain aligned to their expected positions.  
- No freezing, distortion, or misplacement of icons occurs.  
- Camera and gallery remain fully functional in every orientation.  

### ✅ Pass Criteria
- Camera, gallery, and all icons adapt correctly to each orientation.  
- No UI overlap, clipping, or misaligned elements.  
- Smooth transitions between orientations.  
- Media visualization (photos/videos) adapts without distortion.  

### 📎 Notes
- Test across multiple devices (phones and tablets).  
- Validate both front and rear cameras.  
- Validate gallery with photos and videos.  
- Perform the test in both idle mode and during active recording. 