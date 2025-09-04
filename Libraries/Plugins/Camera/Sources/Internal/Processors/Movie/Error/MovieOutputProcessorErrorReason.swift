//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the video device operations.
    ///
    /// The `MovieOutputProcessorErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct MovieOutputProcessorErrorReason: Sendable {
        /// Error indicating that an audio input cannot be added to the movie output.
        ///
        /// This error occurs when the system is unable to add an audio input
        /// to the movie output processor. This can happen due to incompatible
        /// audio formats, missing audio permissions, or system resource limitations.
        static let cannotAddAudioInput = ErrorReason(rawValue: "CANNOT_ADD_AUDIO_INPUT")

        /// Error indicating that a video input cannot be added to the movie output.
        ///
        /// This error occurs when the system is unable to add a video input
        /// to the movie output processor. This can happen due to incompatible
        /// video formats, missing video permissions, or system resource limitations.
        static let cannotAddVideoInput = ErrorReason(rawValue: "CANNOT_ADD_VIDEO_INPUT")

        /// Error indicating that a movie writer cannot be created.
        ///
        /// This error occurs when the system is unable to create an AVAssetWriter
        /// instance for movie output processing. This can happen due to invalid
        /// output URLs, unsupported output formats, or insufficient system resources.
        static let cannotCreateWriter = ErrorReason(rawValue: "CANNOT_CREATE_WRITER")

        /// An error reason indicating that the movie processor cannot be paused in its current state.
        ///
        /// This static property defines a specific error reason for when a pause operation
        /// is attempted on a movie processor that is not in a valid state for pausing.
        static let cannotPauseProcessor = ErrorReason(rawValue: "CANNOT_PAUSE_MOVIE_PROCESSOR")

        /// Error indicating that ending the movie processing operation failed.
        ///
        /// This error occurs when the system is unable to properly finalize
        /// the movie output processing. This can happen due to write failures,
        /// incomplete data, or system errors during the finalization process.
        static let endProcessingFailed = ErrorReason(rawValue: "END_PROCESSING_FAILED")

        /// Error indicating that video output configuration failed.
        ///
        /// This error occurs when the system is unable to configure the video
        /// output settings for movie processing. This can happen due to missing
        /// format descriptions, invalid video dimensions, or incompatible
        /// pixel buffer attributes.
        static let videoOutputConfigurationFailed = ErrorReason(rawValue: "VIDEO_OUTPUT_CONFIGURATION_FAILED")
    }
}
