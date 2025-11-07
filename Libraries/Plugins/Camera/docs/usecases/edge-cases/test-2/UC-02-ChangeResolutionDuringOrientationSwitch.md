# 🎥 Use Case: Change Resolution During Orientation Switch  

## 🎯 Objective  
Validate that switching the **device orientation** while the **Resolution menu** is open does not cause the camera view to freeze or misbehave, and that the selected resolution is correctly applied afterward.  

## 🧪 Test Scope  
- **Included:**  
  - Resolution selector UI behavior during orientation change.  
  - Orientation handling while modal (Resolution menu) is open.  
  - UI recovery and proper dismissal after selecting a resolution.  
- **Excluded:**  
  - Flash, zoom, and recording behavior.  
  - Video or photo capture validation.  
  - Persistence of resolution after app restart.  

## 📝 Preconditions  
- User is authenticated and SDK camera is active.  
- **Camera view** is visible in idle state.  
- Device orientation starts in **portrait** mode.  
- **Resolution selector** is available and functional.  

## ✅ Expected Visible UI Elements  
- **Camera Container**: visible and responsive.  
- **Resolution Button**: visible and tappable.  
- **Resolution Options (e.g., FHD)**: visible when Resolution menu is open.  

## 🚫 Expected Hidden UI Elements  
- **Recording Controls**: not visible while Resolution menu is open.  
- **Orientation overlay warnings**: not displayed during transition.  

## ✋ Interaction Rules  
- **Resolution Button**  
  - Tap once → opens Resolution options.  
- **Device Orientation**  
  - Changing orientation while the menu is open should **not** freeze or reset the camera view.  
- **Resolution Option (FHD)**  
  - Tap → closes menu, updates button label, returns to active camera view.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Ensure device orientation is **portrait**.  
3. Tap the **Resolution button** to open the resolution menu.  
4. Rotate the device to **landscape** orientation.  
5. Select **FHD** (or any available resolution) from the list.  
   - Verify the resolution menu closes.  
   - Verify the selected resolution appears on the button label.  
   - Verify the camera view is visible and responsive.  

### ✅ Expected Result  
- The **camera view** remains stable when switching orientation.  
- Selecting a resolution applies it correctly and returns to the camera preview.  
- No UI freeze, black screen, or crash occurs during or after orientation change.  

## ✅ Pass Criteria  
- The resolution menu closes after selection.  
- The selected resolution (e.g., **FHD**) appears correctly.  
- The camera preview remains visible and responsive.  

## 📎 Notes  
- Validate in both **portrait → landscape** and **landscape → portrait** transitions.  
