# 🧩 Use Case: Configuration Mode - Video and Picture (Total Limit with Fixed Duration)

## 🎯 Objective
Validate that when the SDK camera is configured in **video and picture mode with a total media limit** and a defined **maximum video duration** (e.g., 10 seconds), the user can capture **photos and/or videos** up to the configured total count, and each video recording automatically stops once the maximum duration is reached. There are no individual limits per type.

## 🧪 Test Scope
**Included:**
- Verification that both photo and video capture are enabled.
- Validation that the total number of media items (photo + video) does not exceed the configured limit.
- Validation that each video respects the **configured maximum duration** and stops automatically.
- Verification of UI timer behavior during video recording.

**Excluded:**
- Flash, focus, zoom, quality, or lens orientation validation.
- Audio quality or encoding integrity checks.
- Post-processing or trimming verification.

## ⚙️ Preconditions
- SDK camera initialized in **video and picture mode** with a total media limit (e.g., 5 items).
- Configuration includes `maxDuration = 10 seconds` (or specified limit).
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## 🖼️ Expected Visible UI Elements
- **Capture Button:** visible and enabled for photo capture.
- **Record Button:** visible and enabled for video capture.
- **Count-Up Timer:** shows elapsed time (0 → 10).
- **Countdown Timer:** shows remaining time (10 → 0).
- **Media Counter (if available):** updates after each capture (photo or video).

## 🙈 Expected Hidden UI Elements
- **Mode Switcher:** hidden or disabled (fixed by configuration).
- **Unavailable Controls:** capture controls disabled after reaching total limit.

## 🔄 Interaction Rules
- **Capture Button**
  - Tap → takes a photo and increments total media count.
- **Record Button**
  - Tap once → starts recording; both timers begin.
  - Recording automatically stops at **maxDuration**.
  - Saved video increments total media count.
- SDK must enforce both:
  - **Maximum total media count** (e.g., 5 total captures).
  - **Maximum video duration** (e.g., 10 seconds).

## 🧭 Test Steps
1. Launch the SDK camera with **video and picture mode (total limit)** and `maxDuration = 10s`.
2. Verify that both **Capture** and **Record** buttons are visible and enabled.
3. Start a video recording using the **Record Button**.
4. Observe both timers:
   - **Count-Up Timer:** increases from 0 → 10.
   - **Countdown Timer:** decreases from 10 → 0.
5. Wait for recording to stop automatically once the limit is reached.
6. Verify that the recorded video is saved and counted toward the total media limit.
7. Capture photos and/or videos in any order until reaching the **total media count**.
8. Attempt an additional capture beyond the limit and verify that it is **blocked**.
9. Confirm that each video saved has a duration of **10 seconds** (± tolerance).
10. Observe SDK behavior and UI responsiveness after limit reached.

## ✅ Expected Result
- Both photo and video capture function correctly.
- Each video automatically stops at the configured duration.
- Total media count is enforced (no captures beyond limit).
- Timers display correctly and are synchronized during recording.
- Preview remains active and responsive after captures.

## 🧾 Pass Criteria
- SDK enforces both **total media limit** and **maximum video duration**.
- Videos auto-stop and save correctly at the defined duration.
- Saved media (photo and video) respect configuration limits.
- No crash, freeze, or UI desynchronization occurs.

## 📝 Notes
- This test validates **mixed media mode with fixed video duration** and **total capture limit**.
- For unlimited video duration or per-type limits, refer to the respective test cases.
- Recommended to test with front and rear cameras to verify consistent timer display.
