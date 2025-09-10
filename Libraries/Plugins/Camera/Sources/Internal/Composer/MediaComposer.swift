//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import Utilities
internal import ffmpegkit

/// A protocol defining the interface for composing multiple media assets into a single output.
///
/// The `MediaComposer` protocol provides a standardized interface for combining multiple
/// media files (videos, audio, or both) into a single output file. Implementations of this
/// protocol handle the complex process of media composition, including format conversion,
/// synchronization, and output generation.
///
/// ## Usage
///
/// ```swift
/// let composer: MediaComposer = VideoMerger()
/// let assetURLs = [video1URL, video2URL, audioURL]
/// let outputURL = documentsDirectory.appendingPathComponent("composed.mp4")
///
/// do {
///     try await composer.compose(assetURLs, into: outputURL)
///     print("Media composition completed successfully")
/// } catch {
///     print("Composition failed: \(error)")
/// }
/// ```
protocol MediaComposer {
    /// Composes multiple media assets into a single output file.
    ///
    /// This method takes an array of media file URLs and combines them into a single
    /// output file at the specified destination. The composition process handles
    /// format conversion, synchronization, and proper media merging.
    ///
    /// - Parameters:
    ///   - assetURLs: An array of URLs pointing to the input media files
    ///   - destination: The URL where the composed output file should be saved
    /// - Throws: An error if the composition process fails
    func compose(_ assetURLs: [URL], into destination: URL) async throws
}

struct FFMPEGVideoComposer: MediaComposer {

    // MARK: - MediaComposer

    /// Composes multiple media assets into a single output file.
    ///
    /// This method takes an array of media file URLs and combines them into a single
    /// output file at the specified destination. The composition process handles
    /// format conversion, synchronization, and proper media merging.
    ///
    /// - Parameters:
    ///   - assetURLs: An array of URLs pointing to the input media files
    ///   - destination: The URL where the composed output file should be saved
    /// - Throws: An error if the composition process fails
    func compose(_ assetURLs: [URL], into destination: URL) async throws {
        let inputDestination = destination.deletingLastPathComponent().appendingPathComponent("\(UUID()).txt")
        let inputFileContent = assetURLs.reduce(into: "") { $0 += "file \($1.path)\n" }

        let command = "-y -f concat -safe 0 -i {inputFilesListsPath} -c copy {output}"
            .replacingOccurrences(of: "{inputFilesListsPath}", with: inputDestination.path)
            .replacingOccurrences(of: "{output}", with: destination.sanitizedPath)

        if !FileManager.default.createFile(atPath: inputDestination.path, contents: Data(inputFileContent.utf8)) {
            throw UtilityError(
                kind: .MediaComposerErrorReason.composeFailed,
                failureReason: "Unable to create temporary input file at \(inputDestination.path)"
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            _ = FFmpegKit.executeAsync(
                command,
                withCompleteCallback: { session in
                    if let session, let code = session.getReturnCode() {
                        let sessionState = session.getState()

                        defer { try? FileManager.default.removeItem(atPath: inputDestination.path) }

                        if let failure = FFmpegKitConfig.sessionState(toString: sessionState), code.isValueError() {
                            let error = UtilityError(
                                kind: .MediaComposerErrorReason.composeFailed,
                                failureReason: failure
                            )

                            continuation.resume(throwing: error)
                            return
                        }

                        continuation.resume()
                    }
                },
                withLogCallback: { _ in },
                withStatisticsCallback: nil
            )
        }
    }
}

extension URL {
    /// Returns a sanitized and quoted version of the file path.
    ///
    /// This computed property processes the file path by removing percent encoding
    /// if present and wrapping the result in double quotes. This ensures the path
    /// is properly formatted for use in command-line operations or file system
    /// interactions where spaces or special characters might cause issues.
    fileprivate var sanitizedPath: String {
        if let sanitized = path.removingPercentEncoding {
            return "\"\(sanitized)\""
        }

        return "\"\(path)\""
    }
}
