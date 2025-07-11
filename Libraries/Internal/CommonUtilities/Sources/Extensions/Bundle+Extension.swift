//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Bundle {
    /// Converts logger metadata into a pretty-printed JSON string representation.
    ///
    /// - Parameter metadata: A dictionary of metadata key-value pairs to format.
    /// - Returns: A pretty-printed JSON string, or `nil` if metadata is empty or encoding fails.
    public static func version(of value: AnyClass.Type) -> String {
        let bundle = Bundle(for: value.self)

        if
            /// The version properties file.
            let versionFile = bundle.path(forResource: "version", ofType: "properties"),

            /// The raw lines from the content string.
            let lines = try? String(contentsOfFile: versionFile).components(separatedBy: .newlines) {

            for line in lines {
                let components = line.components(separatedBy: "=")

                if components.count == 2 && components[0] == "version" {
                    return components[1]
                }
            }
        }
        
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
