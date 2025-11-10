# 🧩 Use Case: Configuration Mode - Video Only (Fixed Duration Recording)

## 🎯 Objective
Validate that when the SDK camera is configured in **video-only mode** with a defined **maximum duration per video** (e.g., 10 seconds), the recording automatically stops once the timer reaches the limit. The UI must display both the **elapsed timer (count-up)** and **remaining timer (countdown)** during recording, and the saved video must respect the configured duration.

## 🧪 Test Scope
**Included:**
- Verification that the SDK enforces the configured **maximum video duration**.
- Validation that both **count-up** and **countdown** timers are displayed during recording.
- Verification that recording stops automatically when duration limit is reached.
- Validation that saved video duration matches the configured limit.

**Excluded:**
- Photo capture, flash, focus, zoom, or audio quality validation.
- User manual stop scenarios (handled separately).
- Post-processing or trimming beyond the SDK’s stop behavior.

## ⚙️ Preconditions
- SDK camera initialized in **video-only mode**.
- Configuration includes `maxDuration = 10 seconds` (or any defined limit).
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## 🖼️ Expected Visible UI Elements
- **Record Button:** visible and enabled for video capture.
- **Count-Up Timer:** displays elapsed time (starts at 0 → 10).
- **Countdown Timer:** displays remaining time (starts at 10 → 0).

## 🙈 Expected Hidden UI Elements
- **Capture Button:** hidden or disabled (photo capture not available).
- **Mode Switcher:** hidden or disabled (fixed by configuration).
- **Unavailable Controls:** no inactive media type selectable.

## 🔄 Interaction Rules
- **Record Button**
  - Tap once → starts video recording and both timers begin.
  - Recording automatically stops at the configured **maxDuration**.
  - Video is automatically saved once recording ends.
- SDK must ensure video file duration ≤ configured limit (e.g., 10 seconds ± 0.2s tolerance).

## 🧭 Test Steps
1. Launch the SDK camera with **video-only mode** and `maxDuration = 10s`.
2. Verify that the **Record Button** is visible and enabled.
3. Tap the **Record Button** to start recording.
4. Observe both timers:
   - **Count-Up Timer:** increases from 0 → 10.
   - **Countdown Timer:** decreases from 10 → 0.
5. Wait for recording to stop automatically once the countdown reaches 0.
6. Verify that recording stops **without manual interaction**.
7. Confirm that the video is saved successfully in the gallery or media list.
8. Validate that the saved video duration is **10 seconds** (± small tolerance).
9. Observe UI and SDK behavior after recording completion.

## ✅ Expected Result
- Both timers (count-up and countdown) appear and update in sync during recording.
- Recording stops automatically after reaching 10 seconds.
- Video is saved successfully and has a duration of 10 seconds (± tolerance).
- Preview remains active and responsive after recording ends.
- Record button becomes available again for a new recording (if within limit).

## 🧾 Pass Criteria
- SDK enforces the **maximum video duration** precisely.
- Both timers are displayed and synchronized correctly.
- Video auto-stops and saves correctly at the defined duration.
- No crash, freeze, or timer desync occurs.
- Saved video duration matches configuration (10s ± 0.2s).

## 📝 Notes
- This test validates **fixed-duration behavior** in **video-only mode**.
- For variable or unlimited duration scenarios, refer to “Video Only – Multiple Videos” test case.
- Timer UI alignment and animation smoothness may be validated in separate visual/UI test cases.
