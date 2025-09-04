//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Type alias combining audio and video output processing capabilities.
///
/// The DeviceOutputProcessor type alias creates a unified interface that combines both
/// AudioOutputProcessor and VideoOutputProcessor protocols. This allows implementers to
/// provide coordinated processing of both audio and video streams through a single interface,
/// enabling synchronized media processing operations and unified lifecycle management.
typealias DeviceOutputProcessor = AudioOutputProcessor & VideoOutputProcessor
