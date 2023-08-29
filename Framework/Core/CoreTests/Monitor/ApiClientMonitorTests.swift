//
//  OperatorsTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Alamofire
import XCTest

@testable import Core

final class ApiClientMonitorTests: CoreTests {

    // MARK: Overriden methods

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: Tests

    func testExample() throws {
        // Given
        let testURL = URL(string: "https://www.example.com")!
        let alamoRequest = AF.request(testURL)
        let request = Request(request: alamoRequest, interceptor: nil, monitor: nil)
        let sut = ApiClientMonitor()

        // When
        sut.requestDidResume(request)

        // Then
        
    }
}
