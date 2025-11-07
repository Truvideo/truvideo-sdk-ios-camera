//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Double {
    /// Converts the time interval to a formatted Hours:Minutes:Seconds string.
    ///
    /// This function converts a time interval (in seconds) to a human-readable string
    /// in the format "HH:MM:SS" where hours, minutes, and seconds are zero-padded
    /// to ensure consistent formatting. It's useful for displaying duration values
    /// in user interfaces.
    ///
    /// - Returns: A formatted string in "HH:MM:SS" format with zero-padded values.
    func toHMS() -> String {
        let value = Int(self.rounded())

        let hours = value / 3_600
        let minutes = (value % 3_600) / 60
        let seconds = value % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
