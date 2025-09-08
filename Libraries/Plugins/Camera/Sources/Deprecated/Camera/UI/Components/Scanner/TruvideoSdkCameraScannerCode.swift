//
// Created by TruVideo on 2/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

/// Represents the result of a barcode or QR code scan.
///
/// The `TruvideoSdkCameraScannerCode` class contains **raw barcode data** and its associated **format type**.
///
/// ## Overview
/// When a barcode or QR code is scanned using the **Truvideo Scanner Camera**, this class stores:
/// - The **scanned code's data** (`data`)
/// - The **format of the scanned barcode** (`format`)
///
/// ## Example Usage
/// ```swift
/// let scannedCode = TruvideoSdkCameraScannerCode(data: "123456789", format: .codeQR)
/// print("Scanned Data: \(scannedCode.data)")
/// print("Format: \(scannedCode.format)")
/// ```
@objc public class TruvideoSdkCameraScannerCode: NSObject {
    /// The raw data extracted from the scanned barcode.
    @objc public let data: String

    /// The type of barcode that was scanned.
    @objc public let format: TruvideoSdkCameraScannerCodeFormat

    /// Initializes a scanner result object with the provided barcode data.
    ///
    /// - Parameters:
    ///   - data: The **raw data** captured from the scanned barcode.
    ///   - format: The **barcode format** associated with the scan.
    init(data: String, format: TruvideoSdkCameraScannerCodeFormat) {
        self.data = data
        self.format = format
    }
}
