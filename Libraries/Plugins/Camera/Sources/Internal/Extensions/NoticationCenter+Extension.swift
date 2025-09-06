//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension NotificationCenter {
    /// Posts a notification asynchronously on the main actor.
    ///
    /// This method creates a task that runs on the main actor to post the specified
    /// notification. This ensures that the notification posting occurs on the main
    /// thread, which is important for UI-related notifications and maintaining
    /// thread safety when updating user interface elements.
    ///
    /// - Parameters:
    ///   - notification: The name of the notification to post
    ///   - object: The object posting the notification, or `nil` if no specific object
    ///   - userInfo: Optional dictionary containing additional information about the notification
    func post(_ notification: NSNotification.Name, object: Any?, userInfo: [AnyHashable: Any]? = nil) {
        Task { @MainActor in
            post(name: notification, object: object, userInfo: userInfo)
        }
    }
}
