## 📷 Use Case: Gallery Access After Capturing Media

### 🎯 Objective
Verify that the **Gallery feature** correctly displays photos and videos after being captured, ensuring counters, icons, orientation handling, and navigation work as expected.

### 🧪 Test Scope
- **Included:**
  - Appearance of **Gallery icons** (photo and video) only after at least one file has been captured.
  - Proper increment of **counters** for photos and videos.
  - Gallery entry when tapping icons (photo/video).
  - Ordering of media (newest → oldest).
  - Orientation handling (portrait/landscape, locked/unlocked).
  - Close (X) button functionality inside the Gallery.

- **Excluded:**
  - Uploading or editing media.
  - Third-party gallery apps.

### 📝 Preconditions
- The user is authenticated.
- The SDK camera is initialized and active.
- At least one **photo or video** has been captured.  
- Device has camera and storage permissions granted.

### ✅ Expected Visible UI Elements
- **Photo Gallery Icon (📷)**
  - Appears only after at least one photo is taken.
  - Displays a counter with the number of captured photos.

- **Video Gallery Icon (🎥)**
  - Appears only after at least one video is recorded.
  - Displays a counter with the number of recorded videos.

- **Close (X) Button inside Gallery**
  - Always visible in the current orientation.
  - Closes the Gallery and returns to the camera view.

- **Media List View**  
  - Shows captured files in reverse chronological order (most recent first).  
  - Supports both photo and video previewing.  

### 🚫 Expected Hidden UI Elements
- **Continue Button**: hidden until at least one photo is captured.  
- **Media Counter**: should not be visible at the start.  

### ✋ Interaction Rules
- **Gallery Icons (Photo/Video)**
  - Tap opens the corresponding Gallery (photos or videos).
  - Counters increment correctly with each new capture.

- **Gallery View**
  - Media is listed from newest → oldest.
  - Supports orientation changes dynamically:
    - **Locked orientation** → keeps current orientation.
    - **Unlocked orientation** → rotates to match device (portrait/landscape).

- **Close (X) Button**
  - Always visible, regardless of orientation.
  - Exits Gallery and returns to camera view.

### 📸 Test Steps
1. Launch the SDK camera.  
2. Capture **one photo** → verify Photo Gallery icon appears with counter `1`.  
3. Capture **one video** → verify Video Gallery icon appears with counter `1`.  
4. Capture additional photos and videos → counters update correctly.  
5. Tap the **Photo Gallery icon** → verify list of photos appears from newest → oldest.  
6. Tap the **Video Gallery icon** → verify list of videos appears from newest → oldest.  
7. Rotate the device with **orientation unlocked** → verify Gallery rotates correctly (portrait/landscape).  
8. Lock the device orientation → verify Gallery stays fixed in locked mode.  
9. While in Gallery, tap the **Close (X) Button** → return to camera view. 

**Expected Result:**
- Photo and Video Gallery icons appear only when media exists.
- Counters increment correctly and match actual media count.
- Gallery lists files in descending chronological order.
- Orientation handling works with both locked and unlocked states.
- Close (X) button is always visible and functional.

### ✅ Pass Criteria
- Icons and counters behave as expected.
- Gallery opens and lists files correctly.
- Orientation behaves as specified.
- No crashes, freezes, or misaligned UI occur.

### 📎 Notes
- Validate behavior on devices with different aspect ratios.
- Test in **portrait and all landscape orientations**.
- Ensure icons and counters update in real-time after each capture.