//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Testing

@testable import TruvideoSdk

struct TruVideoAppTests {
    // MARK: - Tests

    @Test
    func testThatAuthentication() async throws {
        let sut = TruVideoApp()
        try sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))
        
        try await sut.authenticate()
    }
}
