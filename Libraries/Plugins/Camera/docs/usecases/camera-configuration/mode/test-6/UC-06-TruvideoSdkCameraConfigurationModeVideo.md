# Use Case: Configuration Mode - Video Only

## Objective
Validate that when the SDK camera is configured with mode set to **video only**, the user can capture **multiple videos** up to the configured limits, with optional maximum duration per video. Picture capture is disabled.

## Test Scope
**Included:**
- Verification that video recording is enabled.
- Validation that multiple videos can be captured up to the configured **maximum video count**.
- Validation that each video respects the optional maximum duration.

**Excluded:**
- Photo capture, flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding beyond basic recording.

## Preconditions
- SDK camera initialized with video-only mode.
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Record Button: visible and enabled for video capture.
- Media Counter (if available): shows captured video count and duration.

## Expected Hidden UI Elements
- Capture Button: hidden or disabled (photo capture not available).
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no inactive media type should be selectable.

## Interaction Rules
- Record Button
  - Tap once → starts video recording.
  - Tap again → stops recording, increments video count.
- The SDK must enforce configured **maximum video count** and optional **maximum duration per video**.

## Test Steps
1. Launch the SDK camera with video-only mode active.
2. Verify that the Record Button is visible and enabled.
3. Start a video recording using the Record Button.
4. Stop the recording and confirm it is successfully saved.
5. Repeat captures until reaching the configured maximum video count.
6. Attempt an additional video capture and verify that it is **blocked**.
7. Verify that each captured video respects the configured maximum duration (if set).
8. Observe SDK behavior after reaching the limit.

## Expected Result
- Video capture is enabled and functional.
- Photo capture is disabled.
- Video count increments correctly after each capture.
- SDK enforces maximum video count and optional duration per video.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows multiple video captures up to the configured limit.
- Videos are saved correctly without errors.
- Configured maximum duration per video is respected (if applicable).
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates video-only mode.
- For mixed media or single video scenarios, use the respective test cases.