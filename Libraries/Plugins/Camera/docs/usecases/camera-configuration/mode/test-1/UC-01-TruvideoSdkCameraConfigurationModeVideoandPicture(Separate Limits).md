# Use Case: Configuration Mode - Video and Picture (Separate Limits)

## Objective
Validate that when the SDK camera is configured with mode set to **video and picture with separate limits**, the user can capture **both videos and pictures**, each respecting its individual maximum limit, and the total media count equals the sum of both limits.

## Test Scope
**Included:**
- Verification that both photo and video capture are enabled.
- Validation that captures respect individual **video** and **picture** limits.
- Validation that total media count equals the sum of video and picture limits.
- Validation of optional maximum video duration.

**Excluded:**
- Flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding beyond basic recording.

## Preconditions
- SDK camera initialized with video and picture mode with separate limits.
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Capture Button: visible and enabled for photo capture.
- Record Button: visible and enabled for video capture.
- Media Counter (if available): updates after each capture.

## Expected Hidden UI Elements
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no inactive media type should be selectable.

## Interaction Rules
- Capture Button
  - Tap → takes a photo, increments picture count.
- Record Button
  - Tap once → starts video recording.
  - Tap again → stops recording, increments video count.
- The SDK must enforce **individual limits** per media type and the **total media count**.

## Test Steps
1. Launch the SDK camera with video and picture mode (separate limits) active.
2. Verify both Capture and Record buttons are visible and enabled.
3. Take photos until reaching the configured picture limit.
4. Take videos until reaching the configured video limit.
5. Attempt additional captures beyond either limit and verify they are blocked.
6. Verify the total media count equals the sum of the individual limits.
7. Verify that each captured video respects the optional maximum duration.
8. Observe SDK behavior after limits are reached.

## Expected Result
- Both photo and video capture are enabled and functional.
- Individual limits for pictures and videos are respected.
- Total media count equals the sum of limits.
- Optional video duration is enforced.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows both photo and video capture respecting individual limits.
- Captures are saved correctly without errors.
- Total media count equals the sum of limits.
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates **mixed media mode with separate limits**.
- For flexible total limits, use the other video and picture mode.
