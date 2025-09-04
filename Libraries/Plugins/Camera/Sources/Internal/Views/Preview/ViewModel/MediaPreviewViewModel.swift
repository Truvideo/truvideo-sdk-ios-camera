//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

final class MediaPreviewViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Dependencies

    private let orientationMonitor: OrientationMonitor

    // MARK: - Published Properties

    /// The current aspect ratio of the camera preview, expressed as height divided by width.
    ///
    /// This property represents the aspect ratio of the camera preview in the format height:width.
    @Published private(set) var aspectRatio: CGFloat = 9 / 16

    /// The collection of media items displayed in the gallery.
    ///
    /// This published property contains all media items (both video clips and photos)
    /// that are currently displayed in the gallery.
    @Published var medias: [Media] = []

    /// The currently selected page index in the tab view.
    ///
    /// This published property tracks the active page index in a horizontal
    /// page-style tab view.
    @Published var selection = 0

    // MARK: - Initializer

    /// Creates a new media preview view model with media collection and orientation monitoring.
    ///
    /// This initializer sets up a view model that manages media preview functionality
    /// with built-in device orientation monitoring. The orientation monitor allows
    /// the view model to respond to device rotation changes and adjust the UI
    /// accordingly, ensuring optimal display of media content in different
    /// orientations.
    ///
    /// - Parameters:
    ///   - medias: The collection of media items to be displayed in the preview
    ///   - orientationMonitor: A monitor that tracks device orientation changes, defaults to DeviceOrientationMonitor
    init(medias: [Media], orientationMonitor: OrientationMonitor = DeviceOrientationMonitor()) {
        self.medias = medias
        self.orientationMonitor = orientationMonitor

        orientationMonitor.add(self)
    }

    // MARK: - Instance methods

    /// Removes the specified media item from the collection.
    ///
    /// This function searches for the given media item in the current collection
    /// and removes it if found. The removal is performed by finding the index
    /// of the media item and then removing it at that position, which maintains
    /// the order of remaining items in the collection.
    func delete() {
        medias.remove(at: selection)
        selection = max(0, selection - 1)
    }

    // MARK: - OrientationMonitorSubscriber

    /// Handles a new device orientation update and applies the corresponding rotation angle.
    ///
    /// This method is triggered when a new `DeviceOrientationInfo` is received.
    /// It updates the current orientation, calculates the transition between the
    /// previous and new orientations, and determines the appropriate rotation angle.
    /// If the orientation source comes from sensors while the device is physically
    /// in portrait mode, it preserves or updates the rotation angle accordingly.
    ///
    /// - Parameter deviceOrientation: The latest orientation information, including its
    ///   source (e.g., system or sensors) and value.
    func didReceive(_ deviceOrientation: DeviceOrientation) {
        switch deviceOrientation.orientation {
        case .landscapeLeft,
            .landscapeRight:

            aspectRatio = 16 / 9

        case .portrait, .portraitUpsideDown:
            aspectRatio = 9 / 16

        default:
            break
        }
    }
}
