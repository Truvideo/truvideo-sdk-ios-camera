# 📘 TruvideoCamera — Changelog & Breaking Changes Guide

## Version 78.2.0

This document describes all major updates, deprecated APIs, and breaking changes introduced in this release of **TruvideoCamera**.  
Please review carefully before upgrading your integration to avoid runtime or authentication issues.

---

## 🔄 Changelog Summary

| Category | Description |
|-----------|--------------|
| **Camera Configuration** | Updated `TruvideoSdkCameraConfiguration` initializer parameters. |

---

## ⚠️ Breaking Changes

### 3. `TruvideoSdkCameraConfiguration` Initializer Updated
**Change Summary:**
Change Summary:

- The initializer parameters for TruvideoSdkCameraConfiguration have been reduced and reordered alphabetically.
- Unused or redundant parameters (frontResolutions, frontResolution, backResolutions, backResolution, orientation) were removed for simplicity.
- This update improves clarity, consistency, and ensures alignment with other SDK components.

**Example Comparison:**

**Before:**
```swift
TruvideoSdkCameraConfiguration(
    lensFacing: lensFacing,
    flashMode: flashMode,
    orientation: orientation,
    outputPath: "",
    frontResolutions: [],
    frontResolution: nil,
    backResolutions: [],
    backResolution: nil,
    mode: cameraModeConfiguration.makeCameraMediaMode(),
    imageFormat: imageFormat
)
```

**Now:**
```swift
TruvideoSdkCameraConfiguration(
    flashMode: flashMode,
    imageFormat: imageFormat,
    lensFacing: lensFacing,
    mode: cameraModeConfiguration.makeCameraMediaMode(),
    outputPath: ""
)
````

**Impact:**

- Code relying on positional arguments (without labels) will break.
- Always use parameter labels for clarity and forward compatibility.


## ✅ Migration Checklist

Before updating to this SDK version: 
- **Review** and update any usage of `TruvideoSdkCameraConfiguration` to ensure parameters are in the new alphabetical order.  
