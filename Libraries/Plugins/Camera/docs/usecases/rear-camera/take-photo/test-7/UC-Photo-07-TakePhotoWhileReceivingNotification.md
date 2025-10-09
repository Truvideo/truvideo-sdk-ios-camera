# 📷 Use Case: Take Photo While Receiving a Notification (Rear Camera)  

## 🎯 Objective  
Verify that the user can take a photo with the **rear camera** while the device receives a **system notification** (e.g., SMS, push notification, app banner), ensuring that the capture is not interrupted.  

## 📝 Preconditions  
- User is authenticated with valid data.  
- The app has been granted **camera permission**.  
- SDK camera is initialized and active.  
- Device has active **system notifications** enabled.  
- Rear camera is available and functional.  

## ✅ Expected Visible UI Elements  
- **Take Photo Button**: visible in idle state.  
- **Flash Toggle**: visible and functional.  
- **Preview**: must remain visible and uninterrupted when a notification banner appears.  

## 🚫 Expected Hidden UI Elements  
- **Pause Button**: not applicable (photo mode).  
- **Gallery Button**: disabled during capture.  
- **Resolution Selector**: disabled during capture.

## ✋ Interaction Rules  
- **Take Photo Button**  
  - Tap → photo must be captured successfully, even if a notification arrives.  
  - Shutter sound must play when the photo is taken.  

- **System Behavior**  
  - **Preview must not freeze** when a notification banner appears.  
  - Photo must be **saved correctly** regardless of the notification.  
  - Notification banner may overlay UI, but **must not block capture process**.  

## 📸 Test Steps  
1. Launch the SDK camera.  
2. Switch to **rear camera**.  
3. Trigger an incoming **notification** (e.g., send SMS or push message to the device).  
4. While the notification is being displayed, tap the **Take Photo Button**.  
   - Verify **shutter sound** plays.

### ✅ Expected Result  
- User can take photos without interruption while notifications appear.  
- Preview remains active and smooth.  
- Shutter sound feedback is consistent.  
- All captured photos are saved correctly.  

### ✅ Pass Criteria  
- No crashes, freezes, or corrupted images.  
- Notifications do not prevent photo capture.  
- Photos align correctly with the device orientation.  

### 📎 Notes  
- Test with different notification types: SMS, push, system alerts.  
- Verify on devices with **Do Not Disturb** and **Focus Modes** enabled/disabled.  
