//
// Copyright © 2025 TruVideo. All rights reserved.
//

import UIKit

protocol TaskManaging {
    func beginBackgroundTask()
    func endBackgroundTask()
}

final class BackgroundTaskManaging: TaskManaging {
    // MARK: - Private Properties

    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    // MARK: - TaskManaging

    func beginBackgroundTask() {
        endBackgroundTaskIfNeeded()
    }

    func endBackgroundTask() {
        endBackgroundTaskIfNeeded()
    }

    // MARK: - Private methods

    private func endBackgroundTaskIfNeeded() {
        if backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        }
    }
}
