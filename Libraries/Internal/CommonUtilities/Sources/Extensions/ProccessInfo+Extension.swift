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
            return "critical"
            
        case .fair:
            return "fair"
            
        case .nominal:
            return "nominal"
            
        case .serious:
            return "serious"

        default:
            return "unknown"
        }
    }
}
