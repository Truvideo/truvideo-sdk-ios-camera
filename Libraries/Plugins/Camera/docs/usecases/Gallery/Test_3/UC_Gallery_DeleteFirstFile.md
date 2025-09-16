## 🗑️ Use Case: Delete First File in Gallery (Position 0)

### 🎯 Objective
Verify that when deleting the **first file (position 0)** in the Gallery viewer, the next file in sequence is automatically displayed with a **left-to-right transition** animation.

### 🧪 Test Scope
- **Included:**  
  - Deletion of a file when it is the first in the Gallery.  
  - Automatic navigation to the next file.  
  - Transition animation behavior.  

- **Excluded:**  
  - Deletion of files in other positions (covered in separate test cases).  
  - Bulk deletion or multi-select deletion.  
  - Editing or uploading files.  

### 📝 Preconditions
- User is authenticated.  
- SDK camera initialized and active.  
- At least **one files** (photo or video) exist in the Gallery.  
- Gallery viewer supports swipe/transition navigation.  

### ✅ Expected Visible UI Elements
- **Media Viewer** (photo or video)  
  - Displays the file currently selected.  

- **Delete (Trash) Button**  
  - Visible and functional inside viewer.  

- **Navigation Controls** (if applicable, e.g., swipe gestures)  
  - Allow navigation between files.  

- **Close (X) Button**  
  - Returns to Gallery list.  

### 🚫 Expected Hidden UI Elements
- Camera capture controls (flash, resolution, etc.) remain hidden inside the Gallery viewer.  

### ✋ Interaction Rules
- **Delete Action**  
  - When file at **position 0** is deleted → it is permanently removed.  

- **Auto-Navigation**  
  - Viewer automatically transitions to **next available file** (position 1).  
  - Transition direction must be **left-to-right**, matching UX navigation rules.  

- **Empty State**  
  - If the deleted file was the only one → viewer closes and returns to empty Gallery.  

### 📸 Test Steps
1. Launch SDK camera and capture at least **two photos or videos**.  
2. Open the Gallery and select the **first file (position 0)**.  
3. Tap the **Delete (Trash) Button**.  
   - Verify file is removed from Gallery.  
4. Verify viewer automatically navigates to the **next file (position 1 → now becomes position 0)**.  
5. Verify the **transition animation** is from **left to right**.  
6. Close the viewer using the **X button** → return to Gallery list.  
7. Verify Gallery list no longer contains the deleted file.  

**Expected Result:**  
- Deleting the first file removes it permanently.  
- Viewer automatically shows the next file.  
- Transition animation is left-to-right.  
- Gallery list is updated without the deleted file.  

### ✅ Pass Criteria
- File at position 0 is deleted successfully.  
- Viewer correctly transitions to next file with left-to-right animation.  
- Gallery reflects updated file list.  
- No crashes, freezes, or UI glitches occur.  

### 📎 Notes
- Validate with both **photos** and **videos**.  
- Repeat with different media counts (2, 3, 5 files) to ensure consistency.  
- Test in both **portrait** and **landscape** orientations.  
