//
// Created by TruVideo on 14/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import Foundation

/// A publisher that emits camera-related events.
///
/// `TruvideoSdkCameraEventObserver` is an **event stream** that broadcasts camera-related actions.
/// It **never fails**, ensuring that all camera event notifications are safely handled.
///
/// ## Example Usage
/// ```swift
/// let eventSubscription: AnyCancellable = TruvideoSdkCamera.events.sink { event in
///     print("Received camera event: \(event.type)")
/// }
/// ```
///
/// - Note: Use this observer to **subscribe to real-time camera events**.
public typealias TruvideoSdkCameraEventObserver = AnyPublisher<TruvideoSdkCameraEvent, Never>

/// A **PassthroughSubject** that sends camera-related events.
///
/// `TruvideoSdkCameraEventPublisher` serves as the internal event dispatcher for the camera system.
/// It enables the broadcasting of **real-time camera events**.
///
/// ## Example Usage
/// ```swift
/// TruvideoSdkCameraEvent.events.send(TruvideoSdkCameraEvent(type: .cameraStarted))
/// ```
typealias TruvideoSdkCameraEventPublisher = PassthroughSubject<TruvideoSdkCameraEvent, Never>

/// Represents a camera event emitted by `TruvideoSdkCamera`.
///
/// `TruvideoSdkCameraEvent` is used to **track specific camera actions**, such as:
/// - Camera started
/// - Camera stopped
/// - Photo captured
/// - Video recorded
///
/// ## Example Usage
///
/// ```swift
/// let event = TruvideoSdkCameraEvent(type: .photoCaptured)
/// print("Event: \(event.type) at \(event.createdAt)")
/// ```
public struct TruvideoSdkCameraEvent {
    /// The event publisher that emits camera-related events.
    ///
    /// This property allows events to be broadcasted across the application.
    static let events = TruvideoSdkCameraEventPublisher()

    /// The type of event triggered.
    ///
    /// Defines the specific camera-related action that occurred.
    public let type: TruvideoSdkCameraEventType

    /// The timestamp of when the event was created.
    ///
    /// This property records the **exact moment** the event was triggered.
    public let createdAt: Date

    /// Initializes a new `TruvideoSdkCameraEvent`.
    ///
    /// - Parameter type: The specific camera event type.
    init(type: TruvideoSdkCameraEventType) {
        self.type = type
        self.createdAt = Date()
    }
}
