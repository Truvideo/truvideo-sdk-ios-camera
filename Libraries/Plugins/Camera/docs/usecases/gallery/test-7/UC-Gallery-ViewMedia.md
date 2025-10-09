## 📷 Use Case: View Photo or Video from Gallery

### 🎯 Objective
Verify that the user can open and view a **specific photo or video** from the Gallery, and that the media is displayed correctly in all supported orientations depending on device rotation settings.

### 🧪 Test Scope
- **Included:**  
  - Opening the Gallery and selecting a photo or video.  
  - Displaying the selected media in the viewer.  
  - Orientation handling (portrait/landscape, locked/unlocked).  
  - Close (X) button behavior in the viewer.  

- **Excluded:**  
  - Editing or deleting media.  
  - Uploading media.  
  - External gallery apps.  

### 📝 Preconditions
- The user is authenticated.  
- The SDK camera is initialized and active.  
- At least one **photo or video** has been captured and is available in the Gallery.  
- Device has **storage access permission**.  

### ✅ Expected Visible UI Elements
- **Photo/Video Preview Viewer**  
  - Opens when a specific media item is tapped in the Gallery.  
  - Displays the full media content (photo or video).  
  - Must render correctly in portrait or landscape.  

- **Close (X) Button**  
  - Always visible in the current orientation.  
  - Closes the media viewer and returns to the Gallery.  

- **Video Playback Controls** (for videos only)  
  - Play/Pause button visible and functional.  
  - Scrubber/timeline available (if supported by SDK).  

### 🚫 Expected Hidden UI Elements
- Gallery icon counters are not shown inside the viewer.  
- Camera controls (flash, capture, resolution, etc.) are hidden while viewing media.  

### ✋ Interaction Rules
- **Gallery Navigation**  
  - User taps a photo → photo opens in full screen.  
  - User taps a video → video opens in full screen with playback controls.  

- **Orientation Handling**  
  - If device rotation is **locked** → viewer remains fixed in portrait.  
  - If rotation is **unlocked** → viewer rotates to match device orientation (portrait/landscape).  

- **Close (X) Button**  
  - Always visible in the viewer.  
  - Returns user to the Gallery when tapped.  

### 📸 Test Steps
1. Launch the SDK camera.  
2. Capture at least one photo and one video.  
3. Tap the **Photo Gallery icon** → enter the photo list.  
4. Select a photo → verify it opens in full screen.  
5. Rotate device:  
   - With rotation locked → photo stays in portrait.  
   - With rotation unlocked → photo rotates according to device orientation.  
6. Close viewer with the **X button** → return to photo list.  
7. Tap the **Video Gallery icon** → enter the video list.  
8. Select a video → verify it opens with playback controls.  
9. Play and pause video → confirm controls work.  
10. Rotate device:  
    - With rotation locked → video stays in portrait.  
    - With rotation unlocked → video rotates according to device orientation.  
11. Close viewer with the **X button** → return to video list.  

**Expected Result:**  
- Selected media (photo or video) opens in full screen.  
- Orientation behavior matches device settings (locked → portrait, unlocked → dynamic).  
- Videos play/pause correctly.  
- Close (X) button always works and returns to Gallery.  

### ✅ Pass Criteria
- Photos and videos open correctly in the viewer.  
- Orientation handling works as specified.  
- Video playback controls function properly.  
- No crashes, UI misalignment, or visual glitches occur.  

### 📎 Notes
- Test on devices with different screen sizes and aspect ratios.  
- Verify smooth transitions when rotating device while media is playing.  
- Ensure viewer always returns to the correct Gallery list (photos or videos).  