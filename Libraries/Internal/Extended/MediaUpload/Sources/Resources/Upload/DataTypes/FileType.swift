//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// An enumeration that defines the high-level categories of supported media.
///
/// `MediaType` represents the semantic classification of a media resource
/// (e.g., video, image, audio, or document). Unlike `FileType`, which specifies
/// the exact file extension (e.g., `.mp4`, `.jpg`, `.pdf`), `MediaType` groups
/// those extensions into broader categories that are meaningful to the TruVideo
/// API and client applications.
///
/// This value is used in the `metadata.type` field when initializing or
/// finalizing uploads, allowing the backend to apply media-specific processing
/// such as thumbnail generation, preview GIF creation, or audio transcription.
public enum MediaType: String, Codable, Sendable {
    /// Video media category.
    ///
    /// Includes formats such as:
    /// - `.mp4`
    /// - `.mov`
    /// - `.avi`
    /// - `.mkv`
    /// - `.flv`
    /// - `.wmv`
    /// - `.3gpp`
    /// - `.webm`
    ///
    /// ## Example Use Cases
    /// - Uploading recorded video clips
    /// - Marketing or training videos
    /// - Video tutorials and product demos
    case video = "VIDEO"

    /// Image media category.
    ///
    /// Includes formats such as:
    /// - `.jpg`
    /// - `.jpeg`
    /// - `.png`
    /// - `.svg`
    ///
    /// ## Example Use Cases
    ///
    /// - Product photography
    /// - Screenshots
    /// - Logos and icons
    /// - Illustrations and diagrams
    case image = "IMAGE"

    /// Audio media category.
    ///
    /// Includes formats such as:
    /// - `.mp3`
    /// - `.wav`
    /// - `.aac`
    /// - `.flac`
    ///
    /// ## Example Use Cases
    ///
    /// - Voice recordings
    /// - Podcasts
    /// - Music tracks
    /// - Transcriptions and dictations
    case audio = "AUDIO"

    /// Document media category.
    ///
    /// Includes formats such as:
    /// - `.pdf`
    ///
    /// ## Example Use Cases
    ///
    /// - Reports
    /// - Manuals
    /// - Contracts
    /// - E-books and reference materials
    case document = "DOCUMENT"
}

/// An enumeration that defines the supported file extensions for media uploads.
///
/// `FileType` provides a standardized way to specify the file extension of media
/// being uploaded to the TruVideo API. The raw value of each case matches the
/// exact string expected by the API for the `fileType` parameter.
///
/// Using `FileType` ensures proper handling of different file formats and
/// automatically associates them with their high-level `MediaType` category.
public enum FileType: String, CaseIterable, Sendable {
    // MARK: - Video File Types

    /// MP4 video file type (`.mp4`).
    ///
    /// The most widely supported video format, commonly used for:
    /// - Online streaming
    /// - Mobile video recording
    /// - Social media content
    /// - Presentations
    ///
    /// ## Characteristics
    /// - Uses H.264/H.265 compression
    /// - Good balance of quality and file size
    /// - Cross-platform compatibility
    case mp4 = "MP4"

    /// MOV video file type (`.mov`).
    ///
    /// Native to Apple QuickTime and widely used in:
    /// - Apple device recordings
    /// - Professional video editing workflows
    /// - High-quality content creation
    ///
    /// ## Characteristics
    ///
    /// - High quality, less compression
    /// - Larger file sizes
    /// - Best suited for editing and production
    case mov = "MOV"

    /// AVI video file type (`.avi`).
    ///
    /// Legacy multimedia container still used in:
    /// - Video archives
    /// - Windows environments
    /// - Cross-platform video playback
    ///
    /// ## Characteristics
    ///
    /// - Large file sizes
    /// - Limited compression
    /// - Broad but outdated support
    case avi = "AVI"

    /// MKV video file type (`.mkv`).
    ///
    /// Flexible open container format, commonly used for:
    /// - HD and 4K video
    /// - Movies and TV shows
    /// - Subtitles and multi-audio tracks
    ///
    /// ## Characteristics
    ///
    /// - High-quality storage
    /// - Supports multiple audio and subtitle streams
    /// - Larger file sizes
    case mkv = "MKV"

    /// FLV video file type (`.flv`).
    ///
    /// Flash Video format, traditionally used for:
    /// - Online video streaming
    /// - Legacy Flash-based players
    ///
    /// ## Characteristics
    ///
    /// - Outdated but still supported
    /// - Compressed for web delivery
    /// - Lower quality than modern formats
    case flv = "FLV"

    /// WMV video file type (`.wmv`).
    ///
    /// Windows Media Video container format commonly used in the Microsoft ecosystem
    /// and in legacy streaming workflows.
    ///
    /// ## Characteristics
    ///
    /// - Strong compatibility with Windows platforms and applications
    /// - Typically smaller file sizes compared to AVI for similar quality
    /// - Proprietary Microsoft format
    case wmv = "WMV"

    /// 3GPP video file type (`.g3pp`).
    ///
    /// Mobile-friendly video format used for:
    /// - Legacy mobile recordings
    /// - Older streaming protocols
    ///
    /// ## Characteristics
    ///
    /// - Optimized for small file sizes
    /// - Lower video quality
    /// - Mobile device compatibility
    case g3pp = "3GPP"

    /// WebM video file type (`.webm`).
    ///
    /// Open format optimized for the web, commonly used for:
    /// - HTML5 video playback
    /// - Web streaming
    /// - Progressive web applications
    ///
    /// ## Characteristics
    ///
    /// - High compression efficiency
    /// - Open and royalty-free
    /// - Modern browsers support
    case webm = "WEBM"

    // MARK: - Image File Types

    /// JPG image file type (`.jpg`).
    ///
    /// A lossy compressed image format, widely used for:
    /// - Photographs
    /// - Web graphics
    /// - Profile images
    ///
    /// ## Characteristics
    ///
    /// - Lossy compression
    /// - Small file sizes
    /// - 24-bit color support
    case jpg = "JPG"

    /// JPEG image file type (`.jpeg`).
    ///
    /// Functionally identical to `.jpg`. Common for:
    /// - High-quality photos
    /// - Web content
    ///
    /// ## Characteristics
    ///
    /// - Alternative extension to `.jpg`
    /// - Same compression and capabilities
    case jpeg = "JPEG"

    /// PNG image file type (`.png`).
    ///
    /// Lossless format widely used for:
    /// - Logos and icons
    /// - Screenshots
    /// - Transparent graphics
    ///
    /// ## Characteristics
    ///
    /// - Lossless compression
    /// - Transparency support
    /// - Larger files than JPEG
    case png = "PNG"

    /// SVG image file type (`.svg`).
    ///
    /// Vector-based image format used for:
    /// - Scalable icons and logos
    /// - Illustrations
    /// - Charts and diagrams
    ///
    /// ## Characteristics
    ///
    /// - Infinite scalability without quality loss
    /// - Small file sizes
    /// - XML-based format
    case svg = "SVG"

    // MARK: - Audio File Types

    /// MP3 audio file type (`.mp3`).
    ///
    /// Widely supported lossy audio format, commonly used for:
    /// - Music distribution
    /// - Podcasts
    /// - Streaming audio
    ///
    /// ## Characteristics
    /// - Lossy compression
    /// - Very small file sizes
    /// - Universally supported
    case mp3 = "MP3"

    /// WAV audio file type (`.wav`).
    ///
    /// Uncompressed audio format used in:
    /// - Professional audio editing
    /// - High-fidelity playback
    ///
    /// ## Characteristics
    /// - Lossless, uncompressed
    /// - Large file sizes
    /// - High audio fidelity
    case wav = "WAV"

    /// AAC audio file type (`.aac`).
    ///
    /// Advanced Audio Coding, commonly used for:
    /// - Streaming platforms
    /// - Mobile music playback
    ///
    /// ## Characteristics
    /// - Better compression than MP3
    /// - Widely supported
    /// - Good quality-size ratio
    case aac = "AAC"

    /// FLAC audio file type (`.flac`).
    ///
    /// Lossless compression format, used for:
    /// - Archiving music
    /// - High-quality audio distribution
    ///
    /// ## Characteristics
    /// - Lossless compression
    /// - Preserves original audio fidelity
    /// - Larger than MP3/AAC but smaller than WAV
    case flac = "FLAC"

    // MARK: - Document File Types

    /// PDF document file type (`.pdf`).
    ///
    /// Portable Document Format, commonly used for:
    /// - Reports
    /// - Invoices
    /// - Manuals and e-books
    ///
    /// ## Characteristics
    /// - Platform-independent
    /// - Preserves formatting and layout
    /// - Supports text, images, and vector graphics
    case pdf = "PDF"

    /// Returns the high-level `MediaType` category for the current file type.
    ///
    /// This computed property provides the semantic grouping of a file extension
    /// into its broader media category (`video`, `image`, `audio`, or `document`).
    /// It allows you to reason about files at a higher level than just extensions,
    /// and ensures consistency when populating the `metadata.type` field required
    /// by the TruVideo API.
    ///
    /// ## Mapping
    /// - **Video**: `.mp4`, `.mov`, `.avi`, `.mkv`, `.flv`, `.g3pp`, `.webm`
    /// - **Image**: `.jpg`, `.jpeg`, `.png`, `.svg`
    /// - **Audio**: `.mp3`, `.wav`, `.aac`, `.flac`
    /// - **Document**: `.pdf`
    ///
    /// ## Example Usage
    /// ```swift
    /// let fileType: FileType = .mp4
    /// let category = fileType.mediaType   // .video
    ///
    /// let params = InitializeParameters(
    ///     fileType: fileType.rawValue,
    ///     parts: 3,
    ///     metadata: [
    ///         "title": .string("Demo Upload"),
    ///         "type": .string(category.rawValue) // "VIDEO"
    ///     ]
    /// )
    /// ```
    ///
    /// By relying on `mediaType`, you avoid manually mapping file extensions
    /// to categories, reducing errors and improving readability.
    public var mediaType: MediaType {
        switch self {
        case .mp4, .mov, .avi, .mkv, .flv, .wmv, .g3pp, .webm:
            .video

        case .jpg, .jpeg, .png, .svg:
            .image

        case .mp3, .wav, .aac, .flac:
            .audio

        case .pdf:
            .document
        }
    }
}
