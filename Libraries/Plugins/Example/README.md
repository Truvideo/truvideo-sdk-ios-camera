# Camera Sample Projects

This directory hosts two sample applications that demonstrate how to integrate the TruVideo Camera SDK from Objective-C and SwiftUI.

## Prerequisites

- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- CocoaPods is **not** required (dependencies use Swift Package Manager)

## Generate Projects

Use the shared make target at the repository root:

```bash
make genbuild
```

This command runs XcodeGen, links dependencies, and opens the generated workspace containing both samples.

## Sample Apps

- `CameraObjectiveCExample` — UIKit + Objective-C host demonstrating bridging APIs, configuration, and callbacks.
- `CameraSwiftUIExample` — SwiftUI app showcasing camera presentation, configuration options, and media review.

## Authentication Setup

Supply demo credentials before launching the samples:

- SwiftUI: edit `CameraSwiftUIExampleApp.swift` (`SampleCredentials.apiKey`, `SampleCredentials.secretKey`, optional `externalId`).
- Objective-C: edit the same properties in `AuthenticationBridge.swift` or override them at launch if needed.

Once configured both apps call `TruvideoSdk.configure` and `TruvideoSdk.authenticate` on launch so the camera is ready immediately on demand.

## Running a Sample

1. Run `make genbuild` (once per change to project.yml).
2. In Xcode, select either `CameraObjectiveCExample` or `CameraSwiftUIExample` scheme.
3. Choose a simulator or connected device (camera access requires a real device).
4. Build & Run (`⌘R`).

## Testing Workflows

- Objective-C sample: Navigate through configuration options, present the camera, capture media, and inspect completion callbacks in logs.
- SwiftUI sample: Open the camera, capture photos/videos, adjust configuration settings, and tap captured items to preview them.

Both samples rely on the same SDK frameworks, so `make genbuild` will rebuild updated SDK components before running.


