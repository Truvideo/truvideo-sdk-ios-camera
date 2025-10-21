//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import Telemetry

/// A test implementation for `TelemetryManagerSubscriber` used for testing purposes.
final class TelemetryManagerSubscriberMock: TelemetryManagerSubscriber {
    // MARK: - Properties

    var receivedReports: [TelemetryReport] = []

    // MARK: - TelemetryManagerSubscriber

    /// Called by `TelemetryManager` when a new telemetry report is dispatched.
    ///
    /// - Parameter report: The telemetry report received.
    func didReceive(_ report: TelemetryReport) {
        receivedReports.append(report)
    }
}
