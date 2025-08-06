# ⏸️ Use Case: While Recording is Paused

## 🎯 Objective

Verify the camera UI and interaction behavior when a video recording session is **paused**. Ensure that only allowed actions are active and that the UI communicates the paused state clearly to the user.

---

## 🧪 Test Scope

This test focuses on the camera view **once recording is paused**, either manually by the user or programmatically. It does **not** cover active recording or post-recording behavior.

---

## ✅ Expected Visible & Interactive UI Elements

In the paused state, the following UI components **must be visible and functional**:

- **▶️ Resume Button**  
  - Replaces the "Pause" button.
  - Tapping this resumes the recording session.
  - Should reflect a clear play/resume symbol.

- **⏹ Stop Button**  
  - Stops the current recording and finalizes the video file.
  - Must be active and responsive.

- **📸 Capture Photo Button**  
  - User can continue capturing photos even when the video is paused.
  - Capturing a photo **must not resume** recording or interfere with session state.

- **🔦 Flash Toggle**  
  - Remains accessible.
  - Should behave consistently with the flash toggle in other states (on/off toggle, visual feedback).

- **❌ Close (X) Button**  
  - **Must remain visible** for layout consistency.
  - **Must stay disabled** to prevent exiting the session accidentally.
  - Should look inactive (e.g., dimmed or greyed out).

---

## 🚫 Expected Hidden or Disabled Elements

- **➡️ Continue Button**  
  - Should not appear until recording has been completed.

- **Media Preview/Review Options**  
  - Not applicable or visible during paused state.

- **Close Button Behavior**  
  - Button remains **non-interactive** and does **not** dismiss the camera.

---

## ✋ Interaction Rules

- **Resume Recording**  
  - Tapping "Resume" must restart video capture without delay.
  - UI should transition smoothly from paused to recording state.

- **Stop Recording**  
  - Finalizes and saves the recording.
  - Must trigger any necessary callbacks or handlers to store the session.

- **Capture Photo**  
  - User can take still images while paused.
  - Each photo should be stored without affecting the video session.

- **Flash Toggle**  
  - Can be adjusted freely.
  - If flash is hardware-restricted during pause (depends on implementation), toggle should be disabled but clearly show the current state.

- **Close Button**  
  - Must not respond to any user interaction.
  - No tap animation, no dismissal.

---

## 📸 Test Steps

1. Start a recording session.
2. Pause the recording.
3. Verify that:
   - Resume and Stop buttons are visible
   - Photo capture and flash toggle remain active
   - Close (X) button is visible but disabled
4. Tap the flash toggle to confirm the state changes.
5. Tap the photo capture button:
   - Photo should be taken successfully
   - Recording should remain paused
6. Tap the close button:
   - Nothing should happen; no feedback or dismissal
7. Tap "Resume":
   - Verify that recording resumes instantly and UI reflects this change

---

## 🧩 Edge Cases

- If resuming causes a crash or delay, flag as high priority.
- If capturing a photo resumes recording unintentionally, this is a functional error.
- If close button dismisses the session while paused, this is a critical UX bug.

---

## ✅ Pass Criteria

- All interactive elements behave as expected during pause.
- UI clearly communicates paused state (visually and behaviorally).
- User can resume, stop, or capture photos without issue.
- Close button is visible but does nothing when tapped.

---

## 🚫 Out of Scope

- Transitions into or out of pause state (already covered in other cases)
- Upload or preview of media
- Behavior after stopping the session

---

## 📎 Notes

- Ensure all behaviors are consistent between front and rear cameras.
- Validate appearance and responsiveness on different screen sizes and orientations.
- Visual feedback for paused state (e.g., dimmed screen or overlay) should be consistent and accessible.

