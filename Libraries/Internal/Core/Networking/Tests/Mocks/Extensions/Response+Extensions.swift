//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

extension Response {
    static func mock(result: Result<String, NetworkingError>) -> Response<String, NetworkingError> {
        Response<String, NetworkingError>(
            data: Data(),
            metrics: nil,
            request: nil,
            response: HTTPURLResponse(
                url: URL(string: "https://httpbin.org/")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            result: result,
            type: .networkLoad
        )
    }
}
