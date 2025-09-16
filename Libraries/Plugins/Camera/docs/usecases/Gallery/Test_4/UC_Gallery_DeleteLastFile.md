## 🗑️ Use Case: Delete Last File in Gallery (Final Position)

### 🎯 Objective
Verify that when deleting the **last file** in the Gallery viewer, the previous file in sequence is automatically displayed with a **right-to-left transition** animation.

### 🧪 Test Scope
- **Included:**  
  - Deletion of a file when it is the last in the Gallery.  
  - Automatic navigation to the previous file.  
  - Transition animation behavior.  

- **Excluded:**  
  - Deletion of files in first or middle positions (covered in separate test cases).  
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
  - When file at **last position** is deleted → it is permanently removed.  

- **Auto-Navigation**  
  - Viewer automatically transitions to the **previous available file**.  
  - Transition direction must be **right-to-left**, matching UX navigation rules.  

- **Empty State**  
  - If the deleted file was the only one → viewer closes and returns to empty Gallery.  

### 📸 Test Steps
1. Launch SDK camera and capture at least **two photos or videos**.  
2. Open the Gallery and navigate to the **last file**.  
3. Tap the **Delete (Trash) Button**.  
   - Verify file is removed from Gallery.  
4. Verify viewer automatically navigates to the **previous file**.  
5. Verify the **transition animation** is from **right to left**.  
6. Close the viewer using the **X button** → return to Gallery list.  
7. Verify Gallery list no longer contains the deleted file.  

**Expected Result:**  
- Deleting the last file removes it permanently.  
- Viewer automatically shows the previous file.  
- Transition animation is right-to-left.  
- Gallery list is updated without the deleted file.  

### ✅ Pass Criteria
- File at last position is deleted successfully.  
- Viewer correctly transitions to previous file with right-to-left animation.  
- Gallery reflects updated file list.  
- No crashes, freezes, or UI glitches occur.  

### 📎 Notes
- Validate with both **photos** and **videos**.  
- Repeat with different media counts (2, 10, ...) to ensure consistency.  
- Test in both **portrait** and **landscape** orientations.  
