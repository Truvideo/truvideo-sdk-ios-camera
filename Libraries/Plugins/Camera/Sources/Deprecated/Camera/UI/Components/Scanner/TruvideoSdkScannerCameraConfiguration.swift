//
// Created by TruVideo on 8/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import AVFoundation

/// Defines the supported barcode and QR code formats for the scanner.
///
/// `TruvideoSdkCameraScannerCodeFormat` provides the available barcode types that the **Truvideo Scanner Camera** can detect.
///
/// ## Supported Formats
/// - `code39`: **Code-39 barcode** (commonly used in logistics and inventory systems)
/// - `code93`: **Code-93 barcode** (an extended version of Code-39 with higher data density)
/// - `codeQR`: **QR Code** (widely used for mobile transactions, payments, and URLs)
/// - `dataMatrix`: **DataMatrix Code** (used in packaging, manufacturing, and tracking applications)
///
/// ## Example Usage
/// ```swift
/// let scannerConfig = TruvideoSdkScannerCameraConfiguration(
///     flashMode: .auto,
///     codeFormats: [.codeQR, .dataMatrix]
/// )
/// ```
@objc public enum TruvideoSdkCameraScannerCodeFormat: Int, CaseIterable, Codable, RawRepresentable {
    /// Code-39 barcode format.
    case code39

    /// Code-93 barcode format.
    case code93

    /// QR Code format.
    case codeQR

    /// DataMatrix barcode format.
    case dataMatrix

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The corresponding value of the raw type.
    public var rawValue: RawValue {
        switch self {
        case .code39:
            return "code39"

        case .code93:
            return "code93"

        case .codeQR:
            return "codeQR"

        case .dataMatrix:
            return "dataMatrix"
        }
    }

    // MARK: - Initializers

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let scannerCodeFormat = TruvideoSdkCameraScannerCodeFormat(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid raw value for TruvideoSdkCameraScannerCodeFormat"
                )
            )
        }

        self = scannerCodeFormat
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "code39":
            self = .code39

        case "code93":
            self = .code93

        case "codeQR":
            self = .codeQR

        case "dataMatrix":
            self = .dataMatrix

        default:
            return nil
        }
    }

    // MARK: - Encoder

    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension [TruvideoSdkCameraScannerCodeFormat] {
    /// Converts the scanner code formats into their respective `AVMetadataObject.ObjectType`.
    var metadataTypes: [AVMetadataObject.ObjectType] {
        map {
            switch $0 {
            case .codeQR:
                return .qr

            case .code39:
                return .code39

            case .code93:
                return .code93

            case .dataMatrix:
                return .dataMatrix
            }
        }
    }
}

/// Represents the result of a barcode validation process.
///
/// The validation result determines whether a scanned barcode is accepted or rejected.
///
/// ## Example Usage
/// ```swift
/// let validation = TruvideoSdkCameraScannerValidationResult.success()
/// print(validation.accept) // true
/// ```
public struct TruvideoSdkCameraScannerValidationResult {
    /// Indicates whether the scanned barcode is **valid**.
    public let accept: Bool

    /// Provides an **optional error message** when validation fails.
    public let message: String?

    /// Initializes a validation result.
    ///
    /// - Parameters:
    ///   - accept: Whether the scanned code is valid.
    ///   - message: An optional message describing why validation failed.
    public init(accept: Bool, message: String? = nil) {
        self.accept = accept
        self.message = message
    }

    /// Returns a **successful validation result**.
    public static func success() -> TruvideoSdkCameraScannerValidationResult {
        .init(accept: true)
    }

    /// Returns a **failed validation result** with an error message.
    public static func fail(message: String) -> TruvideoSdkCameraScannerValidationResult {
        .init(accept: false, message: message)
    }
}

/// A function signature for validating scanned barcodes.
///
/// This typealias defines a **validation function** that determines whether a scanned barcode is valid.
///
/// - Parameter code: The scanned barcode data.
/// - Returns: A validation result indicating success or failure.
///
/// ## Example Usage
/// ```swift
/// let validation: TruvideoSdkCameraScannerValidation = { code in
///     return code.rawValue.contains("TRU") ? .success() : .fail(message: "Invalid format")
/// }
/// ```
public typealias TruvideoSdkCameraScannerValidation = (
    TruvideoSdkCameraScannerCode
) -> TruvideoSdkCameraScannerValidationResult

/// Configuration settings for the **Truvideo Scanner Camera**.
///
/// This class allows developers to customize **flash mode, orientation, supported barcode types, and validation rules**.
///
/// ## Example Usage
/// ```swift
/// let scannerConfig = TruvideoSdkScannerCameraConfiguration(
///     flashMode: .auto,
///     orientation: .portrait,
///     codeFormats: [.codeQR, .dataMatrix],
///     autoClose: true
/// )
/// ```
@objc public class TruvideoSdkScannerCameraConfiguration: NSObject {
    /// Specifies whether the **flash** is enabled during scanning.
    @objc public let flashMode: TruvideoSdkCameraFlashMode

    /// Defines the **camera orientation** during scanning.
    @objc public let orientation: TruvideoSdkCameraOrientation

    /// The list of **barcode formats** that the scanner will detect.
    ///
    /// By default, **all formats are enabled**.
    public let codeFormats: [TruvideoSdkCameraScannerCodeFormat]

    /// A **validation function** that determines whether a scanned barcode is accepted.
    public let validator: TruvideoSdkCameraScannerValidation?

    /// Determines whether the scanner **automatically closes** after a successful scan.
    @objc public let autoClose: Bool

    /// Initializes a scanner configuration with custom settings.
    ///
    /// - Parameters:
    ///   - flashMode: The initial flash mode setting.
    ///   - orientation: The initial camera orientation.
    ///   - codeFormats: The barcode formats to recognize.
    ///   - autoClose: Whether the scanner should close after a successful scan.
    ///   - validator: An optional validation function for barcode scanning.
    ///
    /// ```swift
    /// let config = TruvideoSdkScannerCameraConfiguration(
    ///     flashMode: .auto,
    ///     orientation: .portrait,
    ///     codeFormats: [.codeQR, .dataMatrix],
    ///     autoClose: true
    /// )
    /// ```
    public init(
        flashMode: TruvideoSdkCameraFlashMode,
        orientation: TruvideoSdkCameraOrientation? = nil,
        codeFormats: [TruvideoSdkCameraScannerCodeFormat] = TruvideoSdkCameraScannerCodeFormat.allCases,
        autoClose: Bool = false,
        validator: TruvideoSdkCameraScannerValidation? = nil
    ) {

        self.flashMode = flashMode
        self.orientation = orientation ?? .portrait
        self.codeFormats = codeFormats
        self.validator = validator
        self.autoClose = autoClose
    }

    /// Creates a scanner configuration with default settings.
    ///
    /// - Parameters:
    ///   - flashMode: The desired flash mode.
    ///   - orientation: The camera orientation.
    ///   - autoClose: Whether to automatically close after a scan.
    /// - Returns: A new scanner configuration instance.
    @objc public static func instantiate(
        with flashMode: TruvideoSdkCameraFlashMode,
        orientation: TruvideoSdkCameraOrientation,
        autoClose: Bool = false
    ) -> TruvideoSdkScannerCameraConfiguration {
        .init(
            flashMode: flashMode,
            orientation: orientation,
            codeFormats: TruvideoSdkCameraScannerCodeFormat.allCases,
            autoClose: autoClose,
            validator: nil
        )
    }
}
