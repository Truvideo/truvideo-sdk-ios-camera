# 📷 Use Case: Take Photo in Multiple Orientations (Rear Camera)  

## 🎯 Objective  
Verify that the user can take photos with the **rear camera** in different device orientations (**Portrait, Landscape Left, Landscape Right**) when the device orientation is not locked, ensuring the captured photo matches the orientation of the device at the time of capture.  

## 🧪 Test Scope  
- **Included:**  
  - Taking photos with the **rear camera**.  
  - Verifying orientation behavior during capture.  
  - Playback of **shutter sound** when photo is taken.  

- **Excluded:**  
  - Zoom adjustments (covered in other cases).  
  - Flash ON/OFF functionality (covered in other cases).  
  - Burst photo mode.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera** permission.  
- Device orientation is **not locked** in system settings.  
- SDK camera is properly initialized and launched.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible but not required for this test.  
- **Orientation-aware Preview**: visible and adapting to device rotation.  

## 🚫 Expected Hidden UI Elements  
- **Gallery Button**: disabled while camera is in idle preview.  
- **Resolution Selector**: not available during capture.  
- **Close (X) Button**: disabled only during capture action (if blocked by SDK).  

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo is captured.  
  - Expected behavior: play **shutter sound** and save photo in the current orientation.  

- **Device Orientation**  
  - Must adjust the preview automatically when rotating the device.  
  - Captured photo must align with the current orientation.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to the **rear camera**.  
3. Rotate the device to **Portrait** orientation.  
   - Verify that the preview updates accordingly.  
   - Tap **Take Photo Button**.  
   - Verify **shutter sound** plays and photo is saved in Portrait orientation.  
4. Rotate the device to **Landscape Left** orientation.  
   - Verify preview updates accordingly.  
   - Tap **Take Photo Button**.  
   - Verify photo is saved in Landscape Left orientation.  
5. Rotate the device to **Landscape Right** orientation.  
   - Verify preview updates accordingly.  
   - Tap **Take Photo Button**.  
   - Verify photo is saved in Landscape Right orientation.  

### ✅ Expected Result  
- Each captured photo is correctly saved in the **current orientation** of the device.  
- **Shutter sound** is heard every time a photo is taken.  
- No distortion or incorrect rotation is applied to the captured photo.  

## ✅ Pass Criteria  
- Photo orientation matches device orientation at capture time.  
- Shutter sound is always played when capturing.  
- Photos are not corrupted and are saved successfully.  
- Preview correctly rotates with device orientation.  
- No crashes or freezes occur.  

## 📎 Notes  
- Repeat test in both **natural device orientations** (Portrait and both Landscape modes).  
- Exclude **upside-down Portrait** unless explicitly supported.  
