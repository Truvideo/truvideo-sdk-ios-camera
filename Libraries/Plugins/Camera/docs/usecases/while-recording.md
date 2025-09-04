# 🎥 Use Case: While Recording

## 🎯 Objective

Verify the camera's UI behavior **after recording has started**. Ensure all interactive elements reflect the correct state and user interactions are limited according to the recording constraints.

---

## 🧪 Test Scope

This test covers the **in-recording state** only—starting from the moment recording begins and ending when the recording is paused or stopped.

---

## 📝 Precondition
- The user should be authenticated successfully with correct data

---

## ✅ Expected Visible & Interactive UI Elements

Once recording starts, the following components **must be visible and functional**:

- **⏸ Pause Button**  
  - Replaces the standard "Record" button.
  - Allows temporarily pausing the recording.
  - Tapping it should pause the session and visually reflect the paused state.

- **⏹ Stop Button**  
  - May be combined with the pause button or appear separately.
  - Stops the recording and finalizes the video segment.

- **🔦 Flash Toggle**  
  - Still accessible during recording.
  - User can toggle flash on/off.
  - Some devices or configurations may lock flash in a fixed state (e.g., always on or off)—this should be respected and handled visually.

- **📸 Capture Photo Button**  
  - User can take photos during recording.
  - Tapping it should not interrupt the video recording.
  - Each photo should be saved and tracked appropriately.

- **❌ Close (X) Button**  
  - **Must remain visible** to maintain UI consistency.
  - **Must be disabled** during active recording to prevent accidental exits.
  - Its disabled state should be clearly indicated (e.g., greyed out or visually dimmed).

---

## 🚫 Expected Hidden or Disabled Elements

- **➡️ Continue Button**  
  - Should remain hidden during recording.
  - Will be shown only after media has been captured and recording is stopped.

- **📊 Media Counter**  
  - May be hidden or optional during active recording depending on the design.

- **Close Button Behavior**  
  - As mentioned above, the button must be **non-interactive** during recording.

---

## ✋ Interaction Rules

- **Pause/Stop**  
  - Tapping "Pause" should immediately pause the video (without delay or frame drops).
  - Tapping "Stop" finalizes the recording session.

- **Flash Toggle**  
  - Should be responsive without interrupting the video stream.
  - If flash state is not allowed to change mid-recording, the toggle should be disabled and show current status.

- **Photo Capture**  
  - Tapping the photo button should:
    - Instantly take a photo.
    - NOT pause or affect the ongoing recording.
    - Possibly show a subtle feedback animation (e.g., a quick flash or shutter effect).

- **Close Button**  
  - Must be completely non-functional during recording.
  - Should show a visual cue (like reduced opacity) to indicate it is disabled.

---

## 📸 Test Steps

1. Launch the camera and start recording.
2. Confirm the UI updates correctly:
   - "Record" button changes to "Pause" and/or "Stop"
   - Flash toggle is visible
   - Photo capture button is active
   - Close (X) button is visible but disabled
3. Tap the flash toggle and verify the flash status changes (if allowed).
4. Tap the photo button during recording:
   - Ensure a photo is taken
   - Video continues recording uninterrupted
5. Tap the Close (X) button:
   - Confirm it does **not** exit the camera view
   - No visual feedback (e.g., no response to taps)
6. Tap "Pause" and/or "Stop" to end the recording
   - Ensure transitions are smooth and UI returns to an appropriate post-recording state.

---

## 🧩 Edge Cases

- If flash toggle doesn't work but should, flag it.
- If a photo capture fails or interrupts video recording, it's a critical bug.
- If the close button can be tapped and closes the view during recording, this is a severe usability issue.

---

## ✅ Pass Criteria

- UI updates correctly upon entering recording mode.
- Flash toggle and photo capture remain functional.
- The close button is **disabled** but **visible**.
- No crashes, delays, or visual glitches during recording.

---

## 🚫 Out of Scope

- Behavior before starting or after stopping recording
- Reviewing or uploading captured media
- Timer or countdown behavior prior to recording

---

## 📎 Notes

- Test should be done in both front and rear cameras.
- Confirm behavior in both portrait and landscape orientations.
- Consider testing on low-performance devices to verify stability under recording pressure.

