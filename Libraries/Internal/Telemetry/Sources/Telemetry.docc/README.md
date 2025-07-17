# Telemetry Framework

## 1. What is Telemetry?

Telemetry is the automated process of collecting, transmitting, and analyzing data from remote or distributed systems. In software, telemetry enables applications to report events, errors, performance metrics, and user interactions to a central system for monitoring, diagnostics, and analytics.

## 2. What Does Telemetry Help With?

Telemetry provides critical insights into:
- **System Health:** Detecting crashes, errors, and performance bottlenecks.
- **User Behavior:** Understanding how users interact with your application.
- **Operational Monitoring:** Tracking deployments, feature usage, and system events.
- **Root Cause Analysis:** Quickly identifying the source of issues through contextual data.

By leveraging telemetry, teams can proactively improve reliability, user experience, and operational efficiency.

## 3. Custom Event & Metadata Tracking

The telemetry framework allows developers to capture custom events and attach rich metadata for advanced analytics and diagnostics.

**How to Track Custom Events:**
- Use the `TelemetryManager.shared.captureEvent(name:source:metadata:)` method to log a custom event.
- You can also use `TelemetryManager.shared.capture(_:name:source:metadata:)` to include a message.
- For error events, use `TelemetryManager.shared.capture(_:name:source:metadata:stackFrame:)` to include an error, stack trace, and metadata.

**Attaching Metadata:**
- Metadata is a flexible key-value structure (`Metadata`) that can be attached to any event or breadcrumb.
- Example:
  ```swift
  TelemetryManager.shared.captureEvent(
      name: "video.upload.started",
      source: "VideoUploader",
      metadata: ["fileSize": 10485760, "userId": "12345"]
  )
  ```

**Breadcrumbs:**
- Use `TelemetryManager.shared.capture(_ breadcrumb: Breadcrumb)` to add contextual breadcrumbs.
- Breadcrumbs can also include metadata for richer context.

**Example:**
```swift
let breadcrumb = Breadcrumb(
    severity: .info,
    source: "camera",
    category: "camera.session",
    message: "Camera preview started",
    metadata: ["lens": "front"]
)
TelemetryManager.shared.capture(breadcrumb)
```

---

## 4. Performance & Resource Impact

The telemetry framework is designed to minimize performance overhead and resource usage:

**Buffering & Batching:**
- Events are buffered in memory using a ring buffer (`RingBuffer`) and persisted to disk via `EventDiskBuffer`.
- The buffer has a fixed maximum capacity (e.g., 100 events) to prevent unbounded memory growth.
- Events are flushed (batched and sent to subscribers) when:
  - The buffer is full,
  - A time interval elapses (default: 180 seconds),
  - Or a session ends.

**Persistence & Recovery:**
- Events are written to disk in newline-delimited JSON, allowing recovery after app restarts or crashes.
- This ensures minimal event loss, even in failure scenarios.

**Resource Management:**
- The framework avoids excessive disk and memory usage by:
  - Limiting buffer size,
  - Flushing and clearing buffers regularly,
  - Using efficient serialization.

**Thread Safety:**
- Critical operations (like session management and buffer access) are protected by locks to ensure thread safety.

---

## 5. Automatically Tracked Fields & Their Importance

The telemetry framework automatically collects and attaches the following fields to every telemetry report and event. Each field is included to provide essential context for diagnostics, analytics, and user experience improvement:

| Field            | Description                                                                                  | Importance                                                                 |
|------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `timestamp`      | The date and time when the event or breadcrumb was recorded.                                 | Ensures every event is chronologically ordered and can be correlated with other system or user actions. |
| `session`        | The current user session object, including session ID, start/end time, and status.           | Groups events into user sessions, enabling analysis of user journeys, session lengths, and session-based issues. |
| `context`        | Device and OS context, including model, OS version, CPU architecture, memory, disk, etc.     | Captures device and OS details, making it possible to reproduce issues, segment analytics, and understand environment-specific problems. |
| `installationId` | Unique identifier for the app installation.                                                  | Uniquely identifies an app installation, supporting cohort analysis and long-term tracking without relying on personal data. |
| `severity`       | Severity level of the event or breadcrumb (e.g., INFO, ERROR, DEBUG).                        | Allows filtering and prioritization of events (e.g., errors vs. info). |
| `source`         | The logical source or component where the event originated.                                  | Identifies the component or module where the event originated, speeding up root cause analysis. |
| `breadcrumbs`    | Chronological list of breadcrumbs leading up to the event (if applicable).                   | Provides a timeline of actions leading up to an event, crucial for debugging complex issues. |

**Example of Automatically Tracked Context:**
```json
"context": {
  "device": {
    "model": "iPhone13,4",
    "manufacturer": "Apple",
    "cpuArchitecture": "arm64",
    "memory": { "total": 8589934592, "free": 123456789 },
    "disk": { "total": 128000000000, "free": 64000000000 },
    "battery": { "level": 0.85, "state": "charging", "isLowPowerMode": false },
    "processorCount": 6,
    "thermalState": "nominal",
    "uptimeSeconds": 123456.7
  },
  "osInfo": {
    "name": "iOS",
    "version": "17.5.1"
  },
  "sdks": {
    "cameraSDK": "1.0.0",
    "mediaSDK": "1.0.0",
    "videoSDK": "1.0.0"
  }
}
```

---

## 6. Event Structure & Field Importance

An **Event** represents a structured occurrence in the application, such as an error, user action, or system change. Events are the primary units of telemetry and provide detailed context for diagnostics and analytics.

| Field         | Description                                                                 | Importance                                                                 |
|---------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `name`        | A descriptive name identifying the type of event (e.g., "camera.session.failed"). | Enables categorization and filtering of events for analytics and debugging. |
| `severity`    | The severity level of the event (e.g., info, warning, error).               | Allows prioritization and filtering of events based on impact.              |
| `source`      | The source module or component where the event originated.                  | Helps pinpoint the origin of issues and speeds up root cause analysis.      |
| `message`     | Additional information attached to the event.                               | Provides human-readable context for understanding the event.                |
| `breadcrumbs` | Chronological list of breadcrumbs leading up to the event (if applicable).  | Offers a timeline of actions for debugging complex issues.                  |
| `exception`   | Exception object with message and stack frame (if the event involves an error). | Captures error details and stack trace for effective debugging.             |
| `timestamp`   | The time the event occurred.                                                | Ensures accurate event ordering and correlation with other data.            |
| `metadata`    | Additional structured metadata relevant to the event.                       | Allows attaching custom, structured data for advanced analytics.            |

---

## 7. Breadcrumb Structure & Field Importance

A **Breadcrumb** is a lightweight, timestamped log entry used to capture relevant contextual events leading up to a telemetry report. Breadcrumbs help trace user and system behavior over time and provide insight into the sequence of actions before an error or significant event.

| Field         | Description                                                                 | Importance                                                                 |
|---------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `category`    | Logical grouping for filtering or categorizing related breadcrumbs.          | Enables grouping and filtering of breadcrumbs for better context.           |
| `message`     | Optional message describing the event or context.                           | Adds human-readable context to the breadcrumb.                              |
| `metadata`    | Additional structured metadata for the event.                               | Allows attaching extra details for richer context.                          |
| `severity`    | Severity level of the breadcrumb.                                           | Helps prioritize and filter breadcrumbs based on importance.                |
| `source`      | The source of the breadcrumb (file or component name).                      | Identifies where the breadcrumb originated for easier debugging.            |
| `timestamp`   | When the breadcrumb was recorded.                                           | Ensures breadcrumbs are ordered and can be correlated with events.          |

---

## 8. Default Integrations & System Event Tracking

> **ℹ️ Out-of-the-Box Observability**
>
> The telemetry framework ships with powerful default integrations that automatically capture essential system and application events—no extra setup required

### **SystemEventTrackerIntegration**

Monitors and reports a wide range of system-level events as breadcrumbs, including:

- **App Lifecycle:**
  - App enters foreground/background
  - *Why?* Correlates user actions with app state, helps diagnose issues related to app suspension/resume, and measures session lengths.
- **Battery State:**
  - Charging status, low power mode, battery level
  - *Why?* Identifies if issues (like performance drops or unexpected shutdowns) are related to device power conditions.
- **Device Orientation:**
  - Portrait/landscape changes
  - *Why?* Useful for debugging UI issues, understanding user context, and correlating errors with device posture.
- **Connectivity:**
  - Network status and type changes
  - *Why?* Critical for diagnosing failed uploads, timeouts, or degraded user experiences due to poor connectivity.
- **Memory Warnings:**
  - Low memory conditions
  - *Why?* Helps identify if issues are caused by resource exhaustion, which can lead to crashes or degraded performance.
- **Time Zone Changes:**
  - Device time zone updates
  - *Why?* Ensures accurate event timing and debugging for time-sensitive features, scheduled tasks, or analytics.

These events are automatically attached to telemetry reports, providing rich context for diagnostics and analytics.

---

### **AutoSessionTrackerIntegration**

Ensures session boundaries are well-defined by automatically managing sessions based on app lifecycle events:

- **Session Start:**
  - When the app becomes active
- **Session End:**
  - When the app is backgrounded for a significant period or terminated

This integration helps you track user sessions accurately, without manual intervention.

---

> **✅ Benefit:**
> With these integrations enabled by default, you gain comprehensive system and session tracking for your app, enhancing reliability and observability from day one.

## 9. When to Use an Event or a Breadcrumb

| Type         | Description                                                                 | When to Use                                                                 |
|--------------|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **Event**    | A structured occurrence, such as an error, user action, or system change.   | Log significant actions, errors, or state changes (e.g., "camera.session.failed").   |
| **Breadcrumb** | A lightweight, timestamped log entry for contextual events.                 | Record steps or actions for debugging (e.g., "ButtonClicked", "API called").|

## 10. Example JSON Structure

### Full Telemetry Report Example

```json
{
  "id": "e7b8c9d0-1234-5678-9abc-def012345678",
  "session": {
    "id": "b1e2c3d4-5678-1234-9abc-def012345678",
    "installationId": "a1b2c3d4-5678-1234-9abc-def012345678",
    "startedAt": "2024-06-01T12:30:00Z",
    "endedAt": "2024-06-01T13:00:00Z",
    "errors": 2,
    "status": "ok"
  },
  "context": {
    "device": {
      "model": "iPhone13,4",
      "manufacturer": "Apple",
      "cpuArchitecture": "arm64",
      "memory": { "total": 8589934592, "free": 123456789 },
      "disk": { "total": 128000000000, "free": 64000000000 },
      "battery": { "level": 0.85, "state": "charging", "isLowPowerMode": false },
      "processorCount": 6,
      "thermalState": "nominal",
      "uptimeSeconds": 123456.7
    },
    "osInfo": {
      "name": "iOS",
      "version": "17.5.1"
    },
    "sdks": {
      "cameraSDK": "1.0.0",
      "mediaSDK": "1.0.0",
      "videoSDK": "1.0.0"
    }
  },
  "events": [
    {
      "name": "camera.session.failed",
      "severity": "ERROR",
      "source": "CameraModule",
      "message": "Camera session failed to start",
      "breadcrumbs": [
        {
          "category": "camera.session",
          "message": "Camera preview started",
          "metadata": {
            "lens": "front"
          },
          "severity": "INFO",
          "source": "camera",
          "timestamp": "2024-06-01T12:34:50Z"
        },
        {
          "category": "ui.action",
          "message": "User tapped start",
          "metadata": {
            "button": "Start"
          },
          "severity": "INFO",
          "source": "MainView",
          "timestamp": "2024-06-01T12:34:45Z"
        }
      ],
      "exception": {
        "message": "Session initialization error",
        "stackFrame": {
          "function": "startSession",
          "file": "CameraModule.swift",
          "line": 42
        }
      },
      "timestamp": "2024-06-01T12:34:56Z",
      "metadata": {
        "attempt": 1,
        "userId": "12345"
      }
    },
    {
      "name": "media.upload.success",
      "severity": "INFO",
      "source": "MediaUploader",
      "message": "Media uploaded successfully",
      "breadcrumbs": [
        {
          "category": "media.upload",
          "message": "Upload started",
          "metadata": {
            "fileName": "video.mp4"
          },
          "severity": "INFO",
          "source": "MediaUploader",
          "timestamp": "2024-06-01T12:35:10Z"
        }
      ],
      "timestamp": "2024-06-01T12:35:20Z",
      "metadata": {
        "fileSize": 10485760,
        "duration": 120
      }
    }
  ]
}
```