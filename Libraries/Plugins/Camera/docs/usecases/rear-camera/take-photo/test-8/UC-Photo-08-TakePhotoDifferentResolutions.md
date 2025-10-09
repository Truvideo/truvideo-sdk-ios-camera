# 📷 Use Case: Take Photo in Different Resolutions (Rear Camera)  

## 🎯 Objective  
Verify that the user can take photos with the **rear camera** using different available resolutions (**HD, FHD, SD**) and that the photo output corresponds to the selected resolution.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera permission**.  
- SDK camera is initialized and active.  
- Rear camera is available and functional.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Resolution Selector**: visible before capture, allowing the user to switch between resolutions.  
- **Flash Toggle**: visible and functional.  
- **Preview**: adapts to the selected resolution.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: not applicable (photo mode).  
- **Gallery Button**: disabled during capture. 

## ✋ Interaction Rules  
- **Resolution Selector**  
  - User can switch between **HD, FHD, SD** before taking a photo.  
  - Once selected, the resolution setting applies to the next capture.  
- **Take Photo Button**  
  - Tap → capture photo in the currently selected resolution.  
  - Shutter sound must play on capture.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Select **HD resolution** from the Resolution Selector.  
4. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.  
   - Verify photo is saved in **HD resolution**.  
5. Select **FHD resolution**.  
6. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.  
   - Verify photo is saved in **FHD resolution**.  
7. Select **SD resolution**.  
8. Tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.  
   - Verify photo is saved in **SD resolution**.  

### ✅ Expected Result  
- Photo is captured and saved in the **selected resolution** (HD, FHD, SD).  
- Shutter sound feedback is consistent.  
- No corruption, distortion, or unexpected scaling of the image.  

### ✅ Pass Criteria  
- Correct resolution metadata in captured photos.  
- No crashes or freezes when switching resolutions.  
- Resolution selector updates correctly before capture.  

### 📎 Notes  
- Validate captured image resolution in the **file properties**.  
- Repeat in **portrait** and **landscape orientations**.  
- Confirm behavior when switching resolutions **rapidly**.  
