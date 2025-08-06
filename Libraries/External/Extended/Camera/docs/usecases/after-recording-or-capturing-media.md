# ✅ Use Case: After Recording or Capturing Media

## 🎯 Objective

Verify that the camera interface behaves correctly **after the user has recorded a video or captured at least one photo**. This includes confirming the visibility and interactivity of post-capture UI elements and ensuring users can proceed, continue capturing, or exit.

---

## 🧪 Test Scope

This test focuses on the state of the camera view **after**:
- A video recording has been stopped
- OR at least one photo has been captured

It covers the available actions and UI adjustments presented to the user at this point.

---

## 📝 Precondition
- The user should be authenticated successfully with correct data

---

## ✅ Expected Visible & Interactive UI Elements

After capturing media, the following components **must be visible and fully functional**:

- **➡️ Continue Button**  
  - Becomes visible as soon as at least one media item is available.
  - Tapping it should lead the user to the media review or confirmation screen.

- **🧮 Media Counter**  
  - Shows the current count of media items (e.g., `2 photos`, `1 video`, or a combined count).
  - Should update in real-time with each new capture.

- **📐 Resolution Selector**  
  - User can freely change the resolution again.
  - Should not affect already captured media.

- **🎥 Capture Controls**  
  - The user can:
    - Start a **new recording**
    - Take additional **photos**
  - These actions should not remove or overwrite existing media.

- **🔄 Camera Switch Button**  
  - Available for switching between front and rear cameras.
  - Must not clear previously captured media.

- **🔦 Flash Toggle**  
  - Fully available for use.
  - Reflects and modifies current flash state.

- **❌ Close (X) Button**  
  - Now **enabled** and fully interactive.
  - Tapping it should allow the user to exit the camera.
  - It may prompt a confirmation if there is unsaved media (optional, depending on implementation).

---

## 🚫 Expected Hidden or Disabled Elements

- No expected hidden elements at this point. All relevant buttons should be visible.

---

## ✋ Interaction Rules

- **Continue Button**  
  - Tapping navigates away from the camera to the next step in the flow.
  - If no media exists, this button should **not** be shown or should be disabled.

- **Media Counter**  
  - Dynamically updates as more media is captured.

- **Flash, Resolution, and Camera Switch**  
  - All must be functional and responsive.
  - State changes should not interfere with already captured content.

- **Close Button**  
  - Must now be **enabled**.
  - Should allow the user to exit the camera view.
  - (Optional) May trigger a prompt: "Discard captured media?"

---

## 📸 Test Steps

1. Start the camera.
2. Capture at least one media item (photo or video).
3. Confirm that:
   - The "Continue" button is visible
   - The media counter appears and reflects the correct count
   - All standard camera controls are re-enabled
   - The close button becomes active
4. Try switching cameras and confirm the previously captured media is retained.
5. Tap the flash toggle, change resolution — ensure the state updates without issues.
6. Tap the close button:
   - Confirm the view exits or a discard confirmation is shown (depending on implementation).
7. Tap the "Continue" button:
   - Verify it transitions to the expected next step (e.g., media review).

---

## 🧩 Edge Cases

- If "Continue" appears without any media captured, this is a bug.
- If switching resolution or camera causes media loss, this is a major issue.
- If the media counter is inaccurate or doesn't update, this should be flagged.
- If the close button does not exit the view or remains disabled, it's a functional issue.

---

## ✅ Pass Criteria

- "Continue" button and media counter appear only after capturing media.
- The user regains access to all capture-related controls.
- No loss of captured media upon toggling flash, switching cameras, or changing resolution.
- Close button works properly and reflects the correct enabled state.

---

## 🚫 Out of Scope

- Uploading or submitting media
- Previewing or editing media
- Timer functionality before capture

---

## 📎 Notes

- Confirm consistent behavior across devices and OS versions.
- Should be tested with various sequences:
  - Photo → Video → Photo
  - Video only
  - Photo only
- Validate that UI remains responsive even after multiple captures.