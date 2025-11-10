# Use Case: Configuration Mode - Video and Picture (Total Limit)

## Objective
Validate that when the SDK camera is configured with mode set to **video and picture with a total limit**, the user can capture **either videos or pictures**, up to the configured **total media count**, with optional maximum video duration. There are no individual limits per type.

## Test Scope
**Included:**
- Verification that both photo and video capture are enabled.
- Validation that the total number of media items does not exceed the configured limit.
- Validation of optional maximum video duration.

**Excluded:**
- Flash, focus, zoom, quality, or lens orientation behavior.
- Audio integrity or media encoding beyond basic recording.

## Preconditions
- SDK camera initialized with video and picture mode (total limit).
- Device has camera and microphone permissions granted.
- User is authenticated and SDK properly configured.
- App is in foreground and preview is visible.

## Expected Visible UI Elements
- Capture Button: visible and enabled for photo capture.
- Record Button: visible and enabled for video capture.
- Media Counter (if available): updates after each capture.

## Expected Hidden UI Elements
- Mode Switcher: hidden or disabled (fixed by configuration).
- Unavailable Controls: no additional captures beyond total limit should be selectable.

## Interaction Rules
- Capture Button
  - Tap → takes a photo, increments total media count.
- Record Button
  - Tap once → starts video recording.
  - Tap again → stops recording, increments total media count.
- The SDK must enforce that the **total media count** does not exceed the configured limit.
- Optional video duration must be enforced if configured.

## Test Steps
1. Launch the SDK camera with video and picture mode (total limit) active.
2. Verify both Capture and Record buttons are visible and enabled.
3. Capture photos and/or videos in any combination until reaching the total media limit.
4. Attempt additional captures beyond the total limit and verify they are blocked.
5. Verify that each captured video respects the configured maximum duration (if set).
6. Observe SDK behavior after reaching the total media limit.

## Expected Result
- Both photo and video capture are enabled and functional.
- Total media count is enforced; no captures beyond the limit.
- Optional video duration is respected.
- The preview remains active and responsive throughout.

## Pass Criteria
- SDK allows mixed media capture up to the total configured limit.
- Captures are saved correctly without errors.
- Configured maximum duration for videos is respected (if applicable).
- No crash, freeze, or mode conflict occurs.

## Notes
- This test validates **mixed media mode with a total limit**.
- For strict individual limits, use the separate limits mode.
- Recommended to test with both front and rear cameras.
