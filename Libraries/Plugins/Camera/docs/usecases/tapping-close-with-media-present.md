# ❌ Use Case: Tapping Close with Media Present

## 🎯 Objective

Ensure that when the user taps the **Close (X)** button after capturing media (photos or videos), a confirmation alert is shown to prevent accidental data loss, and that the options provided behave correctly.

---

## 🧪 Test Scope

This test case focuses on the behavior triggered when the **close button is tapped** after **at least one media item** (photo or video) has been recorded or captured.

It does **not** cover the behavior of the close button in other states (e.g., before capture or during recording).

---

## 📝 Precondition
- The user should be authenticated successfully with correct data

---

## ✅ Expected Behavior

If the user has captured any media, tapping the **Close (X)** button must:

1. **Trigger a confirmation alert** with:
   - A clear **warning** that all recorded media will be discarded.
   - Two distinct action buttons:
     - **“Discard”** (or equivalent)
     - **“Cancel”**

2. Ensure **no media is deleted** until the user explicitly confirms by tapping “Discard”.

---

## 📋 Alert Content

- **Title (optional):**  
  _“Discard Media?”_

- **Message:**  
  _“Exiting now will discard all captured photos and videos. Are you sure you want to continue?”_

- **Buttons:**
  - **🗑 Discard**
    - Immediately exits the camera.
    - Deletes all unsaved/captured media from the current session.
  - **↩️ Cancel**
    - Dismisses the alert.
    - Returns the user to the camera view with media preserved.

---

## ✋ Interaction Rules

- Tapping **“Discard”**:
  - The camera view should close immediately.
  - No photos or videos from the current session should be retained.
  - Any in-memory media should be cleared.

- Tapping **“Cancel”**:
  - The alert should close.
  - The user remains in the camera view.
  - All previously captured media is preserved and accessible.

- Tapping outside the alert (if applicable):
  - Should be treated the same as tapping "Cancel" (optional, based on UX policy).

---

## 📸 Test Steps

1. Launch the camera.
2. Capture at least one media item (photo or video).
3. Tap the **Close (X)** button.
4. Verify that a confirmation alert appears with:
   - A clear discard warning
   - Two options: "Discard" and "Cancel"
5. Tap **Cancel**:
   - The alert is dismissed.
   - User returns to the camera.
   - Previously captured media is still accessible.
6. Tap **Close (X)** again.
7. This time, tap **Discard**:
   - The camera view exits.
   - All media captured during the session is discarded.
   - (Optional) Confirm that no media persists in memory or file system after exit.

---

## 🧩 Edge Cases

- If the alert **does not appear** after capturing media, this is a critical bug.
- If **Cancel** deletes media or exits the view, this is incorrect.
- If **Discard** fails to exit or leaves media behind, flag for review.
- If user can bypass the confirmation (e.g., via gesture or hardware button), this should be tested for consistency.

---

## ✅ Pass Criteria

- Alert always appears when trying to close the camera with media present.
- Both buttons behave as expected:
  - "Cancel" keeps the user in the camera.
  - "Discard" exits and deletes all current session media.
- No crashes, media leaks, or unexpected state transitions occur.

---

## 🚫 Out of Scope

- Behavior of the close button before capturing any media.
- Saving or uploading media.
- Confirmation alerts in other parts of the app.

---

## 📎 Notes

- Alert text and button labels may vary slightly depending on localization or platform conventions.
- Consider testing with multiple captured items (e.g., 10+ photos) to confirm performance and consistency.
- Ensure that any temporary media storage is correctly cleaned after "Discard".

