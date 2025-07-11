//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import Networking

extension NetworkingError {
    public static let errorMock = NetworkingError(kind: .sessionInvalidated, failureReason: "failureReason")
}
