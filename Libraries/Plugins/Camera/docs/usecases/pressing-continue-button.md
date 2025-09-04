# ➡️ Use Case: Pressing Continue Button

## 🎯 Objective

Ensure that tapping the **“Continue”** button properly ends the camera session and returns the captured media (photos and/or videos) to the parent module, delegate, or calling context.

---

## 🧪 Test Scope

This test case focuses on the **“Continue”** action, which becomes available **after** the user has captured at least one media item. It verifies the final transition from the camera to the next step in the application flow.

---

## 📝 Precondition
- The user should be authenticated successfully with correct data

---

## ✅ Expected Behavior

Once media (photo or video) has been captured:

- The **Continue button** becomes visible and active.
- When tapped:
  1. The **camera interface is dismissed or closed**.
  2. The set of captured media items is **returned to the parent context**.
     - This may include:
       - Image data or file URLs
       - Video clips or file references
     - Depending on implementation, this may be sent via:
       - Delegate method
       - Completion handler
       - Callback function
       - Notification or event

---

## ✋ Interaction Rules

- **Availability:**
  - The “Continue” button must be hidden or disabled **until** the user captures at least one media item.

- **Tapping "Continue":**
  - Must immediately end the camera session.
  - All UI elements related to capture should be dismissed.
  - Captured media is passed to the application logic that handles preview, upload, or storage.
  - The user is taken to the next logical screen in the flow (e.g., review screen, upload form, confirmation step).

---

## 📸 Test Steps

1. Launch the camera.
2. Capture one or more photos or videos.
3. Confirm that the **“Continue”** button appears.
4. Tap **“Continue”**.
5. Verify that:
   - The camera interface is dismissed.
   - The app navigates to the next screen or calls the expected delegate/handler.
   - All captured media is passed correctly and is accessible in the next context.
   - No media is lost or missing in transition.

---

## 🧩 Edge Cases

- If the “Continue” button is active with **no media captured**, this is a bug.
- If tapping “Continue” causes a **crash**, freezes the UI, or fails to close the camera, this must be flagged.
- If the parent module **receives an empty or incorrect media list**, it's a critical integration error.

---

## ✅ Pass Criteria

- “Continue” is only available after media capture.
- Tapping “Continue” results in:
  - Proper dismissal of the camera.
  - Accurate and complete transfer of all media data.
  - Smooth transition to the next screen or module.
- No memory leaks or resource retention after closing.

---

## 🚫 Out of Scope

- Displaying or editing captured media after continue.
- Upload logic or server communication.
- Saving media to the device’s photo library (unless explicitly triggered).

---

## 📎 Notes

- Media should be passed in a clear, predictable format (e.g., `[MediaItem]`, `[URL]`, custom struct).
- If the camera supports both photos and videos, validate that **both types are included** in the result.
- Consider adding analytics/logging to track when the user completes the capture flow.