//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct SessionDelegateTests {
    
    // MARK: - Tests
    
    @Test
    func testThatDidReceiveAuthenticationChallengeShouldEvaluateTheAuthChallenge() async {
        // Given
        let monitor = MonitorMock()
        let serverTrustEvaluator = ServerTrustEvaluatorMock()
        let serverTrustEvaluatorProvider = DefaultServerTrustEvaluatorProvider(
            evaluators: ["httpbin.org": serverTrustEvaluator]
        )
        let session = Session(monitors: [monitor], serverTrustEvaluatorProvider: serverTrustEvaluatorProvider)
        
        // When
        _ = await session.request("https://httpbin.org/Auth/get_basic_auth__user___passwd_").serializingData()
        
        // Then
        #expect(monitor.urlSessionTaskDidReceiveAuthenticationChallengeCallCount == 1)
    }
    
    @Test
    func testThatDidReceiveAuthenticationChallengeShouldFailTheRequestOnServerTrustEvaluationFailure() async {
        // Given
        let monitor = MonitorMock()
        let serverTrustEvaluator = ServerTrustEvaluatorMock()
        let serverTrustEvaluatorProvider = DefaultServerTrustEvaluatorProvider(
            evaluators: ["httpbin.org": serverTrustEvaluator]
        )
        let session = Session(monitors: [monitor], serverTrustEvaluatorProvider: serverTrustEvaluatorProvider)        
        
        // When
        serverTrustEvaluator.error = NSError(domain: "", code: 0)
        let response = await session.request("https://httpbin.org/get").serializingData()
        
        // Then
        #expect(monitor.urlSessionTaskDidReceiveAuthenticationChallengeCallCount == 1)
        #expect(response.error?.kind == .serverTrustEvaluationFailed)
    }
}
