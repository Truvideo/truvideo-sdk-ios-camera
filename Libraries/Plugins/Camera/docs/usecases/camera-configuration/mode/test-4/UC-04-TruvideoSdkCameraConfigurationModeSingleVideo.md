# Use Case: Configuration Mode - Single Video

## Objective
Validate that when the SDK camera is configured with mode set to **single video**, the user can capture **exactly one video** with an optional duration limit, and picture capture is disabled.

## Test Scope
**Included:**
- Verification that video recording is enabled.
- Validation that only **one video** can be captured.
- Validation that the video respects the optional maximum duration limit.

**Excluded:**
- Photo capture, flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding beyond basic recording.

## Preconditions
- SDK camera initialized with single video mode.
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Record Button: visible and enabled for video capture.
- Media Counter (if available): shows the captured video count and duration.

## Expected Hidden UI Elements
- Capture Button: hidden or disabled (photo capture not available).
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no inactive media type should be selectable.

## Interaction Rules
- Record Button
  - Tap once → starts video recording.
  - Tap again → stops recording and increments video count.
- The SDK must enforce that only **one video** can be captured and optionally respect the maximum duration.

## Test Steps
1. Launch the SDK camera with single video mode active.
2. Verify that the Record Button is visible and enabled.
3. Start a video recording using the Record Button.
4. Stop the recording and confirm it is successfully saved.
5. Attempt an additional video capture and verify that it is **blocked**.
6. Verify that the captured video respects the configured maximum duration (if any).
7. Observe SDK behavior after the single video capture.

## Expected Result
- Video capture is enabled and functional.
- Photo capture is disabled.
- Only **one video** can be captured; any additional attempts are blocked.
- The captured video respects the configured maximum duration.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows exactly one video capture under this configuration.
- Video is saved correctly without errors.
- Configured duration limit is respected (if set).
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates single-video mode.
- For multiple videos or mixed media, use the respective test cases.
