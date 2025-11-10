# Use Case: Configuration Mode - Picture only

## Objective
Validate that when the SDK camera is configured with mode set to **picture only**, the user can capture photos up to the configured limit, and video capture is disabled.

## Test Scope
**Included:**
- Verification that photo capture is enabled.
- Validation that captures respect the maximum allowed picture count.

**Excluded:**
- Video recording, flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding tests.

## Preconditions
- SDK camera initialized with picture mode.
- Device has camera permission granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Capture Button: visible and enabled for photo capture.
- Media Counter (if available): updates after each capture.

## Expected Hidden UI Elements
- Record Button: hidden or disabled (video capture not available).
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no inactive media type should be selectable.

## Interaction Rules
- Capture Button
  - Tap → takes a photo, increments the picture count.
- The SDK must automatically enforce maximum picture count.

## Test Steps
1. Launch the SDK camera with picture mode active.
2. Verify that the Capture Button is visible and enabled.
3. Take a photo using the Capture Button.
4. Confirm it is successfully saved.
5. Repeat captures until reaching the configured limit (if any).
6. Attempt an additional capture beyond the limit and verify that it is blocked.
7. Observe SDK behavior when the limit is reached.

## Expected Result
- Photo capture is enabled and functional.
- Video capture is disabled.
- Picture count increments correctly after each capture.
- SDK enforces maximum picture count — no additional captures beyond allowed count.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows only photo capture under this configuration.
- Captures are saved correctly without errors.
- Configured picture limit is respected.
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates picture-only mode.
- Use other test cases to validate mixed media, video-only, limit, and duration configurations.
- Recommended to test with both front and rear cameras to confirm consistent handling.
