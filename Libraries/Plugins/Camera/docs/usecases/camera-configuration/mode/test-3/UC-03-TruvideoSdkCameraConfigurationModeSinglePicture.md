# Use Case: Configuration Mode - Single Picture

## Objective
Validate that when the SDK camera is configured with mode set to **single picture**, the user can capture **exactly one photo**, and video capture is disabled.

## Test Scope
**Included:**
- Verification that photo capture is enabled.
- Validation that only **one photo** can be captured.

**Excluded:**
- Video recording, flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding tests.

## Preconditions
- SDK camera initialized with single picture mode.
- Device has camera permission granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Capture Button: visible and enabled for photo capture.
- Media Counter (if available): shows the captured photo count.

## Expected Hidden UI Elements
- Record Button: hidden or disabled (video capture not available).
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no inactive media type should be selectable.

## Interaction Rules
- Capture Button
  - Tap → takes a photo, increments the picture count.
- The SDK must enforce that only **one photo** can be captured.

## Test Steps
1. Launch the SDK camera with single picture mode active.
2. Verify that the Capture Button is visible and enabled.
3. Take a photo using the Capture Button.
4. Confirm it is successfully saved.
5. Attempt an additional capture and verify that it is **blocked**.
6. Observe SDK behavior after the single capture.

## Expected Result
- Photo capture is enabled and functional.
- Video capture is disabled.
- Only **one photo** can be captured; any additional attempts are blocked.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows exactly one photo capture under this configuration.
- Capture is saved correctly without errors.
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates single-picture mode.
- For multiple pictures or mixed media, use the respective test cases.
