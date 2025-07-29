//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A mock subclass of `FileManager` used for testing purposes.
///
/// This mock overrides the `removeItem(at:)` method to capture the URL passed to it,
/// instead of actually removing the file. This allows tests to verify that the method
/// was called with the expected URL, without modifying the file system.
final class FileManagerMock: FileManager {
    /// Stores the URL passed to the `removeItem(at:)` method.
    var url: URL?

    /// Overrides `removeItem(at:)` to store the URL instead of performing the actual removal.
    ///
    /// - Parameter URL: The file URL that would be removed in a real implementation.
    override func removeItem(at URL: URL) throws {
        self.url = URL
    }
}
