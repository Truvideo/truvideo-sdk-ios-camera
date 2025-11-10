# Use Case: Configuration Mode - Single Video or Picture

## Objective
Validate that when the SDK camera is configured with mode set to **single video or picture**, the user can capture **exactly one media item**, either a video or a picture, but not both. The video can optionally have a maximum duration.

## Test Scope
**Included:**
- Verification that either photo or video capture is enabled.
- Validation that only **one media item** can be captured.
- Validation that the video respects the optional maximum duration limit.

**Excluded:**
- Capturing more than one media item.
- Flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding beyond basic recording.

## Preconditions
- SDK camera initialized with single video or picture mode.
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Capture Button: visible and enabled for photo capture.
- Record Button: visible and enabled for video capture.
- Media Counter (if available): shows captured media count and duration (if video).

## Expected Hidden UI Elements
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no additional captures beyond one media item should be selectable.

## Interaction Rules
- Capture Button
  - Tap → takes a photo, increments media count.
- Record Button
  - Tap once → starts video recording.
  - Tap again → stops recording, increments media count.
- The SDK must enforce that only **one media item** can be captured, regardless of type.
- Optional video duration must be enforced if configured.

## Test Steps
1. Launch the SDK camera with single video or picture mode active.
2. Verify that both Capture and Record buttons are visible and enabled.
3. Take a photo or start a video recording using the respective button.
4. Stop the recording if applicable and confirm it is successfully saved.
5. Attempt an additional capture (photo or video) and verify that it is **blocked**.
6. Verify that a captured video respects the configured maximum duration (if set).
7. Observe SDK behavior after the single media capture.

## Expected Result
- Either photo or video capture is enabled and functional.
- Only **one media item** can be captured; any additional attempts are blocked.
- Optional video duration limit is respected.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows exactly one media capture under this configuration.
- Media is saved correctly without errors.
- Configured duration limit is respected (if applicable).
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates single media (video or picture) mode.
- For multiple captures or mixed media, use the respective test cases.
- Recommended to test with both front and rear cameras to confirm consistent handling.
