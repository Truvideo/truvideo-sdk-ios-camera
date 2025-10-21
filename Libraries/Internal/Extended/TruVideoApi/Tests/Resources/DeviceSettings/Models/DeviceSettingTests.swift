//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import TruVideoApi

struct DeviceSettingTests {
    // MARK: - Tests

    @Test
    func testThatDecode() throws {
        // Given
        let fileURL = Bundle(for: BundleLocator.self).url(forResource: "device-settings", withExtension: "json")
        let data = try Data(contentsOf: fileURL!)

        // When, Then
        _ = try JSONDecoder().decode(DeviceSetting.self, from: data)
    }
}
