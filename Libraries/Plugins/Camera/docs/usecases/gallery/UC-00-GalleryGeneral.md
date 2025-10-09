# 🖼️ Use Case: General Gallery Functionality  

## 🎯 Objective  
Verify the general functionality of the **Gallery feature** within the SDK, ensuring that the base workflow for viewing, accessing, and deleting media works correctly across all device orientations and is stable enough to support the extended gallery actions.  

## 🧪 Test Scope  
- **Included:**  
  - General validation of accessing the Gallery after capturing media.  
  - Viewing photos and videos.  
  - Deleting media files.  
  - Orientation handling (locked/unlocked).  
  - Navigation between media items.  

- **Excluded:**  
  - Editing, uploading, or sharing media (covered in other workflows).  
  - Specific orientation or deletion edge cases (covered in dedicated use cases).  

## 📝 Preconditions  
- User is authenticated with valid data.  
- SDK camera is initialized and active.  
- Device has **storage access** permission.  
- At least **one media file (photo or video)** exists in the Gallery.  

## ✅ Expected Visible UI Elements  
- **Photo/Video Gallery Icons** → visible if media exists.  
- **Media Viewer** → displays selected photo or video.  
- **Close (X) Button** → always visible in current orientation.  
- **Delete (Trash) Button** → visible when media is being viewed.  
- **Navigation Controls** (swipe gestures or next/previous buttons) → visible when multiple media exist.  

## 🚫 Expected Hidden UI Elements  
- Camera controls (flash, capture, timer, etc.) are hidden in the Gallery.  
- Multi-select or bulk delete options are hidden unless supported in specific UC.  

## ✋ Interaction Rules  
- **Accessing Gallery**  
  - Tapping photo or video icon opens the corresponding media list.  
- **Media Viewing**  
  - Tapping a media item opens it in full screen with proper orientation handling.  
- **Deletion**  
  - Delete button removes media immediately and navigates automatically to the next or previous item.  
- **Orientation Handling**  
  - Locked orientation → Gallery remains in fixed orientation.  
  - Unlocked orientation → Gallery rotates according to device orientation.  

## 📸 Test Steps  
1. Launch the SDK camera and ensure **media exists** in the Gallery.  
2. Open the Gallery → verify media icons, counters, and thumbnails appear.  
3. Select a media item → verify full-screen preview opens.  
4. Rotate device (locked and unlocked scenarios) → verify orientation handling.  
5. Delete media at **first position**, **last position**, or a specific media → verify correct navigation and animations.  
6. Close viewer → return to Gallery list.  
7. Capture new media → verify Gallery updates and counters increment correctly.  

### ✅ Expected Result  
- Gallery opens and displays media correctly.  
- Orientation handling works as specified (locked/unlocked).  
- Deletion works and navigates correctly to next/previous media.  
- UI controls (close, delete, navigation) are functional and correctly positioned.  

## ✅ Pass Criteria  
- Gallery functions correctly in all scenarios.  
- No crashes, freezes, or misaligned UI elements.  
- Media is viewable and deletable as expected.  
- Counters update in real-time after media capture or deletion.  

## 📎 Notes  
- Validate with **photos and videos**.  
- Test in **portrait and landscape orientations**.  
- Test across devices with different screen sizes.  

### 📂 Specific Use Cases Covered
- UC_Gallery_CameraOrientationLocked.md  
- UC_Gallery_CameraOrientationUnlocked.md  
- UC_Gallery_DeleteFirstFile.md  
- UC_Gallery_DeleteLastFile.md  
- UC_Gallery_DeleteMediaViewer.md  
- UC_Gallery_AccessAfterCapture.md  
- UC_Gallery_ViewMedia.md
