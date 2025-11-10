# 🧩 Use Case: Configuration Mode - Single Video (Fixed Duration)

## 🎯 Objective
Validate that when the SDK camera is configured in **single video mode** with a defined **maximum duration** (e.g., 10 seconds), the recording automatically stops once the timer reaches the configured limit. The UI must display both the **elapsed timer (count-up)** and **remaining timer (countdown)**, and the saved video must respect the configured duration. Only one video can be recorded in this mode.

## 🧪 Test Scope
**Included:**
- Verification that the SDK enforces the configured **maximum video duration**.
- Validation that recording stops automatically at the limit.
- Verification that only one video can be recorded in this configuration.
- Validation that both **count-up** and **countdown** timers are displayed during recording.

**Excluded:**
- Photo capture, flash, focus, zoom, or audio quality validation.
- User manual stop scenarios (handled separately).
- Post-processing or trimming validation beyond SDK’s stop behavior.

## ⚙️ Preconditions
- SDK camera initialized with **single video mode**.
- Configuration includes `maxDuration = 10 seconds` (or defined limit).
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
  - Tap once → starts video recording; both timers begin.
  - Recording automatically stops once **maxDuration** is reached.
  - After recording stops, SDK blocks any further video attempts.
- The SDK must ensure video file duration ≤ configured limit (e.g., 10 seconds ± 0.2s).

## 🧭 Test Steps
1. Launch the SDK camera with **single video mode** and `maxDuration = 10s`.
2. Verify that the **Record Button** is visible and enabled.
3. Tap the **Record Button** to start recording.
4. Observe both timers:
   - **Count-Up Timer:** increases from 0 → 10.
   - **Countdown Timer:** decreases from 10 → 0.
5. Wait until recording automatically stops at the limit.
6. Verify that the video is saved successfully.
7. Attempt a second recording and verify that the SDK blocks it.
8. Confirm that the saved video duration is **10 seconds** (± tolerance).
9. Observe UI and SDK behavior after recording ends.

## ✅ Expected Result
- Recording starts and both timers display correctly.
- Recording stops automatically at the 10-second mark.
- The video is saved successfully and limited to 10 seconds.
- Any additional recording attempts are blocked.
- The preview remains active and responsive after recording.

## 🧾 Pass Criteria
- SDK enforces **single video limit** and **maximum duration** precisely.
- Video auto-stops and saves correctly at defined duration.
- Saved video duration matches configuration (10s ± 0.2s).
- No crash, freeze, or mode conflict occurs.

## 📝 Notes
- This test validates **fixed-duration single-video mode**.
- For multiple videos or unlimited duration, refer to the respective **Video Only** test cases.