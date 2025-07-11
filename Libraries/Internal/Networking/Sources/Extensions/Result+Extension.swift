//
// Copyright © 2025 TruVideo. All rights reserved.
//

extension Result {
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var failure: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        
        return error
    }
}
