## 📷 Use Case: Delete Photo or Video from Gallery Viewer

### 🎯 Objective
Verify that the user can delete a **specific photo or video** only while viewing it in the Gallery viewer, and that deletion behaves correctly in both locked and unlocked orientations.

### 🧪 Test Scope
- **Included:**  
  - Deleting a photo or video from the media viewer.  
  - Correct navigation when deleting with multiple media available.  
  - Confirming deletion across different orientations (portrait/landscape).  

- **Excluded:**  
  - Bulk deletion of multiple files (not supported).  
  - Editing or renaming media.  
  - External device gallery management.  
  - Delete confirmation dialog (not implemented).  

### 📝 Preconditions
- The user is authenticated.  
- The SDK camera is initialized and active.  
- At least **two media files (photo/video)** exist in the Gallery.  
- Device has **storage access permission**.  

### ✅ Expected Visible UI Elements
- **Photo/Video Viewer**  
  - Displays selected media in full screen.  
  - Correctly renders in portrait or landscape depending on device orientation.  

- **Delete (Trash) Button**  
  - Visible only while viewing a media file.  
  - When tapped, immediately deletes the media.  

- **Close (X) Button**  
  - Always visible in the viewer.  
  - Exits back to the Gallery list (photos or videos).  

### 🚫 Expected Hidden UI Elements
- No option to **select multiple media** for bulk deletion.  
- No delete option available outside the viewer (e.g., in Gallery list view).  

### ✋ Interaction Rules
- **Delete Button**  
  - Active only when a photo or video is being viewed.  
  - Removes the media immediately after being pressed (no confirmation).  

- **Orientation Handling**  
  - If device rotation is **locked** → viewer stays in portrait while deleting.  
  - If rotation is **unlocked** → viewer rotates according to device orientation.  

- **Close (X) Button**  
  - Returns to the Gallery without affecting media unless deletion occurred.  

- **Post-deletion Navigation**  
  - If more media exists → automatically display the **next available file**.  
  - If deleted file was the last one → return to the Gallery list (with empty state if no media remains).  

### 📸 Test Steps
1. Launch the SDK camera.  
2. Capture at least **one media file** (photo or video).  
3. Open the Gallery → select a photo or video to view.  
4. Tap the **Delete (Trash) Button**.  
   - The selected media (photo or video) is immediately removed.  
5. If more media exists → viewer automatically displays the **next available file**.  
6. If no more media exists → user is returned to the Gallery list (empty state).  
7. Rotate the device while viewing a photo or video:  
   - With rotation locked → viewer remains in portrait.  
   - With rotation unlocked → viewer adapts to current orientation (portrait or landscape).  

**Expected Result:**  
- When deleting a file with others available, the **next media file** is shown immediately.  
- When deleting the last file, user returns to the Gallery list.  
- Orientation handling works correctly while deleting media.  

### ✅ Pass Criteria
- Delete button only works when media is being viewed.  
- Media is deleted immediately without confirmation.  
- Correct navigation occurs depending on whether more files remain.  
- No crashes, misaligned UI, or orphaned media references occur.  

### 📎 Notes
- Verify both single and multiple media deletion flows.  
- Ensure the **media counter and icons** update correctly after deletion.  
- Test deletion flow for both photos and videos.  
- Confirm UI alignment on devices with different aspect ratios.  