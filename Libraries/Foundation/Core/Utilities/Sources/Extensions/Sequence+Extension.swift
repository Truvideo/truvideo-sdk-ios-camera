//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    /// Returns a new array containing the elements of the collection with duplicate
    /// values removed, preserving the order of their first occurrence.
    ///
    /// This method iterates over the collection and keeps track of elements that
    /// have already been seen. When an element appears for the first time, it is
    /// included in the result; subsequent occurrences of the same element are
    /// ignored.
    ///
    /// For example:
    ///
    ///     let orientations = ["portrait", "landscapeRight", "portrait", "portraitUpsideDown"]
    ///     let unique = orientations.removeDuplicates()
    ///     // unique == ["portrait", "landscapeRight", "portraitUpsideDown"]
    ///
    /// - Returns: A new array containing the unique elements of the collection in
    ///            the order of their first appearance.
    public func removeDuplicates() -> [Element] {
        var seen: Set<Element> = []

        return filter { orientation in
            guard seen.contains(orientation) else {
                seen.insert(orientation)
                return true
            }

            return false
        }
    }
}
