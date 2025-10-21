//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit

extension ProcessInfo.ThermalState: @retroactive CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case .critical:
            "critical"

        case .fair:
            "fair"

        case .nominal:
            "nominal"

        case .serious:
            "serious"

        default:
            "unknown"
        }
    }
}
