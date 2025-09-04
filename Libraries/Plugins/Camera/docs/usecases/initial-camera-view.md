# 📷 Use Case: Initial Camera View

## 🎯 Objective

Verify that the initial state of the camera view correctly presents all expected UI elements and hides those that should not yet be shown. Ensure the user can interact with allowed components (e.g., close button) **only if no media has been captured**.

---

## 🧪 Test Scope

This test focuses exclusively on the **initial state** of the camera view upon launch. It does **not** cover behaviors that occur **after** capturing media or starting a recording.

---

## 📝 Precondition
- The user should be authenticated successfully with correct data

---

## ✅ Expected Visible UI Elements

The following components **must be visible** when the camera is launched:

- **🔦 Flash Toggle**  
  - A button that allows toggling the flash on/off.
  - Should reflect the current flash state.

- **📐 Resolution Selector**  
  - Allows the user to switch between available resolutions (e.g., 1920x1080, 1280x720, 640x480).
  - Should display the selected resolution.
  - HD is the default selected resolution.

- **🔍 Zoom Indicator**  
  - Displays the current zoom level (e.g., 1x, 2x, 3x, 4x, 5x, 6x).
  - May be interactive or passive, depending on implementation.

- **⏱ Timer Control**  
  - Lets users set a countdown before photo capture.
  - Should show the current timer value (Off, 3s, 10s, etc.).

- **🎥 Capture Controls**  
  - Includes:
    - **Photo button**
    - **Video recording button**
  - Only one should be active at a time depending on the selected mode.

- **🔄 Camera Switch Button**  
  - Allows switching between front and rear cameras.

- **❌ Close (X) Button**  
  - Should be visible.
  - Must be functional (tap-to-close) **only if no media has been captured yet**.

---

## 🚫 Expected Hidden UI Elements

The following components **must NOT** be visible at this stage:

- **➡️ Continue Button**  
  - Used for moving to the next screen after capturing media.
  - Should remain hidden until at least one piece of media is available.

- **🧮 Media Counter**  
  - Displays how many photos/videos have been captured.
  - Should not be present at launch.

---

## ✋ Interaction Rules

- **Close (X) Button**  
  - Tappable and should dismiss the camera view immediately.
  - If the user captures or records media, this button behavior may change in later stages.

- **Other buttons** (flash, resolution, etc.)  
  - Must respond to taps and update their state accordingly (if interactive).
  - Any animations or transitions (e.g., toggling flash) should be smooth and error-free.

---

## 📸 Test Steps

1. Launch the camera.
2. Verify that the following components are visible:
   - Flash toggle
   - Resolution selector
   - Zoom indicator
   - Timer
   - Capture controls (photo/video)
   - Camera switch
   - Close (X) button
3. Confirm that these elements are **not visible**:
   - Continue button
   - Media counter
4. Tap the **Close (X)** button.
   - Expectation: the camera closes if **no media has been captured**.

---

## 🧩 Edge Cases

- If the camera fails to load (black screen, error), the test fails immediately.
- If the close button does **not** dismiss the camera with no media present, this is a functional issue.
- If any hidden elements (like Continue or Media Counter) appear too early, this should be flagged.

---

## ✅ Pass Criteria

- All expected elements are present and correctly displayed.
- All hidden elements remain hidden.
- The close button works as expected with no media captured.
- No UI glitches or crashes occur during this state.

---

## 🚫 Out of Scope

- Capturing photos or videos
- Timer countdown behavior
- Media preview or review screen
- Upload or save functionality

---

## 📎 Notes

This test should be performed across:
- Multiple devices (phones/tablets)
- Different orientations (portrait/landscape)
- Front and rear cameras
