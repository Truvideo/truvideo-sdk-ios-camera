//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Data {
    /// A function that returns a pretty-printed JSON string representation of the data.
    ///
    /// This function attempts to convert the data into a JSON object and then back into
    /// a data object with pretty-printed formatting. If the conversion is successful,
    /// it returns the resulting string. Otherwise, it returns `nil`.
    ///
    /// - Returns: A pretty-printed JSON string if the conversion is successful; otherwise, `nil`.
    public func prettyPrintedJSON() -> String? {
        guard
            /// The `JSON` object.
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            
            /// The `JSON` data representation.
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {

            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
