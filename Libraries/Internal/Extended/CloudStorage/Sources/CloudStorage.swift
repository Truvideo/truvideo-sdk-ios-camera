//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// An enumeration that defines common MIME content types for file uploads.
///
/// `ContentType` provides a standardized way to specify the MIME type of files
/// being uploaded to cloud storage services. This ensures proper handling of
/// different file formats and enables appropriate content processing by the
/// storage service and client applications.
public enum ContentType: String, CaseIterable, Sendable {
    // MARK: - Text Content Types

    /// Plain text content type for simple text files.
    ///
    /// This content type is used for plain text files that contain unformatted text
    /// without any special formatting or markup. It's commonly used for:
    /// - Configuration files
    /// - Log files
    /// - Readme files
    /// - Simple text documents
    /// - Code files (when not using specific language content types)
    ///
    /// ## File Extensions
    /// - `.txt`
    /// - `.log`
    /// - `.conf`
    /// - `.ini`
    ///
    /// ## Example Usage
    /// ```swift
    /// let textData = "Hello, World!".data(using: .utf8)!
    /// cloudStorage.upload(textData, fileName: "readme.txt", contentType: .plain)
    /// ```
    case plain = "text/plain"

    /// HTML content type for web pages and HTML documents.
    ///
    /// This content type is used for HTML files that contain markup for web pages.
    /// It's commonly used for:
    /// - Web pages
    /// - HTML email templates
    /// - Documentation pages
    /// - Rich text content
    ///
    /// ## File Extensions
    /// - `.html`
    /// - `.htm`
    /// - `.xhtml`
    ///
    /// ## Example Usage
    /// ```swift
    /// let htmlData = "<html><body><h1>Hello World</h1></body></html>".data(using: .utf8)!
    /// cloudStorage.upload(htmlData, fileName: "index.html", contentType: .html)
    /// ```
    case html = "text/html"

    /// CSV (Comma-Separated Values) content type for tabular data.
    ///
    /// This content type is used for CSV files that contain tabular data separated
    /// by commas or other delimiters. It's commonly used for:
    /// - Data exports
    /// - Spreadsheet data
    /// - Database exports
    /// - Analytics data
    /// - User lists
    ///
    /// ## File Extensions
    /// - `.csv`
    /// - `.tsv` (Tab-Separated Values)
    ///
    /// ## Example Usage
    /// ```swift
    /// let csvData = "name,age,city\nJohn,30,NYC\nJane,25,LA".data(using: .utf8)!
    /// cloudStorage.upload(csvData, fileName: "users.csv", contentType: .csv)
    /// ```
    case csv = "text/csv"

    // MARK: - Image Content Types

    /// JPEG image content type for compressed photographic images.
    ///
    /// This content type is used for JPEG images that use lossy compression
    /// to reduce file size while maintaining good visual quality. It's commonly used for:
    /// - Photographs
    /// - Web images
    /// - Profile pictures
    /// - Product images
    /// - Social media content
    ///
    /// ## File Extensions
    /// - `.jpg`
    /// - `.jpeg`
    /// - `.jpe`
    ///
    /// ## Characteristics
    /// - Lossy compression
    /// - Good for photographs
    /// - Smaller file sizes
    /// - 24-bit color support
    ///
    /// ## Example Usage
    /// ```swift
    /// let imageData = UIImage(named: "photo")?.jpegData(compressionQuality: 0.8)
    /// cloudStorage.upload(imageData!, fileName: "profile.jpg", contentType: .jpeg)
    /// ```
    case jpeg = "image/jpeg"

    /// JSON content type for structured data interchange.
    ///
    /// This content type is used for JSON (JavaScript Object Notation) data,
    /// a lightweight format commonly used for transmitting structured data
    /// between a server and a client. It's widely adopted due to its simplicity,
    /// readability, and compatibility with most programming languages.
    ///
    /// ## Common Uses
    /// - REST API requests and responses
    /// - Configuration files
    /// - Data serialization
    /// - Web applications
    /// - Mobile applications
    ///
    /// ## File Extensions
    /// - `.json`
    ///
    /// ## Characteristics
    /// - Human-readable text format
    /// - Lightweight and language-independent
    /// - Easy to parse and generate
    /// - Supports objects, arrays, strings, numbers, booleans, and null
    ///
    /// ## Example Usage
    /// ```swift
    /// let payload: [String: Any] = ["id": 123, "name": "Darien"]
    /// let jsonData = try? JSONSerialization.data(withJSONObject: payload)
    /// cloudStorage.upload(jsonData!, fileName: "data.json", contentType: .json)
    /// ```
    ///
    case json = "application/json"

    /// PNG image content type for lossless compressed images.
    ///
    /// This content type is used for PNG images that use lossless compression
    /// to maintain image quality without data loss. It's commonly used for:
    /// - Graphics and logos
    /// - Screenshots
    /// - Images with transparency
    /// - Line art and diagrams
    /// - Icons and buttons
    ///
    /// ## File Extensions
    /// - `.png`
    ///
    /// ## Characteristics
    /// - Lossless compression
    /// - Transparency support
    /// - Good for graphics
    /// - Larger file sizes than JPEG
    ///
    /// ## Example Usage
    /// ```swift
    /// let imageData = UIImage(named: "logo")?.pngData()
    /// cloudStorage.upload(imageData!, fileName: "logo.png", contentType: .png)
    /// ```
    case png = "image/png"

    /// GIF image content type for animated and simple images.
    ///
    /// This content type is used for GIF images that support animation and
    /// simple color palettes. It's commonly used for:
    /// - Animated images
    /// - Simple graphics
    /// - Icons and avatars
    /// - Memes and social media content
    /// - Loading animations
    ///
    /// ## File Extensions
    /// - `.gif`
    ///
    /// ## Characteristics
    /// - Animation support
    /// - Limited color palette (256 colors)
    /// - Transparency support
    /// - Good for simple graphics
    ///
    /// ## Example Usage
    /// ```swift
    /// let gifData = try Data(contentsOf: gifURL)
    /// cloudStorage.upload(gifData, fileName: "animation.gif", contentType: .gif)
    /// ```
    case gif = "image/gif"

    /// WebP image content type for modern web-optimized images.
    ///
    /// This content type is used for WebP images that provide superior compression
    /// compared to JPEG and PNG while maintaining quality. It's commonly used for:
    /// - Web images
    /// - Photographs
    /// - Graphics with transparency
    /// - Modern web applications
    /// - Progressive web apps
    ///
    /// ## File Extensions
    /// - `.webp`
    ///
    /// ## Characteristics
    /// - Superior compression
    /// - Animation support
    /// - Transparency support
    /// - Modern web standard
    ///
    /// ## Example Usage
    /// ```swift
    /// let webpData = try Data(contentsOf: webpURL)
    /// cloudStorage.upload(webpData, fileName: "photo.webp", contentType: .webp)
    /// ```
    case webp = "image/webp"

    /// SVG image content type for scalable vector graphics.
    ///
    /// This content type is used for SVG images that are vector-based and
    /// can be scaled without quality loss. It's commonly used for:
    /// - Icons and logos
    /// - Illustrations
    /// - Charts and diagrams
    /// - Responsive graphics
    /// - Web graphics
    ///
    /// ## File Extensions
    /// - `.svg`
    /// - `.svgz` (compressed SVG)
    ///
    /// ## Characteristics
    /// - Vector-based
    /// - Scalable without quality loss
    /// - Small file sizes
    /// - XML-based format
    ///
    /// ## Example Usage
    /// ```swift
    /// let svgData = try Data(contentsOf: svgURL)
    /// cloudStorage.upload(svgData, fileName: "icon.svg", contentType: .svg)
    /// ```
    case svg = "image/svg+xml"

    /// BMP image content type for uncompressed bitmap images.
    ///
    /// This content type is used for BMP images that store pixel data without
    /// compression. It's commonly used for:
    /// - Screenshots
    /// - Simple graphics
    /// - Legacy applications
    /// - Windows system images
    /// - Print graphics
    ///
    /// ## File Extensions
    /// - `.bmp`
    /// - `.dib`
    ///
    /// ## Characteristics
    /// - Uncompressed
    /// - Large file sizes
    /// - Good for simple graphics
    /// - Widely supported
    ///
    /// ## Example Usage
    /// ```swift
    /// let bmpData = try Data(contentsOf: bmpURL)
    /// cloudStorage.upload(bmpData, fileName: "screenshot.bmp", contentType: .bmp)
    /// ```
    case bmp = "image/bmp"

    /// TIFF image content type for high-quality raster images.
    ///
    /// This content type is used for TIFF images that support high-quality
    /// raster graphics with various compression options. It's commonly used for:
    /// - Professional photography
    /// - Print graphics
    /// - Document scanning
    /// - Medical imaging
    /// - Scientific imaging
    ///
    /// ## File Extensions
    /// - `.tiff`
    /// - `.tif`
    ///
    /// ## Characteristics
    /// - High quality
    /// - Multiple compression options
    /// - Professional standard
    /// - Large file sizes
    ///
    /// ## Example Usage
    /// ```swift
    /// let tiffData = try Data(contentsOf: tiffURL)
    /// cloudStorage.upload(tiffData, fileName: "photo.tiff", contentType: .tiff)
    /// ```
    case tiff = "image/tiff"

    /// ICO image content type for Windows icon files.
    ///
    /// This content type is used for ICO files that contain Windows icons
    /// in various sizes and color depths. It's commonly used for:
    /// - Application icons
    /// - Website favicons
    /// - Windows system icons
    /// - Desktop shortcuts
    /// - Browser bookmarks
    ///
    /// ## File Extensions
    /// - `.ico`
    ///
    /// ## Characteristics
    /// - Multiple sizes in one file
    /// - Windows standard
    /// - Favicon support
    /// - Limited color support
    ///
    /// ## Example Usage
    /// ```swift
    /// let icoData = try Data(contentsOf: icoURL)
    /// cloudStorage.upload(icoData, fileName: "favicon.ico", contentType: .ico)
    /// ```
    case ico = "image/x-icon"

    // MARK: - Video Content Types

    /// MP4 video content type for compressed video files.
    ///
    /// This content type is used for MP4 video files that use H.264 compression
    /// and are widely supported across platforms. It's commonly used for:
    /// - Online videos
    /// - Mobile video recording
    /// - Video streaming
    /// - Social media content
    /// - Video presentations
    ///
    /// ## File Extensions
    /// - `.mp4`
    /// - `.m4v`
    /// - `.m4p`
    ///
    /// ## Characteristics
    /// - H.264 compression
    /// - Widely supported
    /// - Good quality/size ratio
    /// - Streaming capable
    ///
    /// ## Example Usage
    /// ```swift
    /// let videoData = try Data(contentsOf: videoURL)
    /// cloudStorage.upload(videoData, fileName: "presentation.mp4", contentType: .mp4)
    /// ```
    case mp4 = "video/mp4"

    /// MOV video content type for Apple QuickTime video files.
    ///
    /// This content type is used for MOV video files that are the native
    /// format for Apple QuickTime. It's commonly used for:
    /// - Apple device recordings
    /// - Professional video editing
    /// - High-quality video content
    /// - Video post-production
    /// - Apple ecosystem content
    ///
    /// ## File Extensions
    /// - `.mov`
    /// - `.qt`
    ///
    /// ## Characteristics
    /// - Apple QuickTime format
    /// - High quality
    /// - Professional standard
    /// - Large file sizes
    ///
    /// ## Example Usage
    /// ```swift
    /// let movData = try Data(contentsOf: movURL)
    /// cloudStorage.upload(movData, fileName: "video.mov", contentType: .mov)
    /// ```
    case mov = "video/quicktime"

    /// AVI video content type for Audio Video Interleave files.
    ///
    /// This content type is used for AVI video files that are a legacy
    /// container format for video and audio. It's commonly used for:
    /// - Legacy video content
    /// - Windows media files
    /// - Video archives
    /// - Older video recordings
    /// - Cross-platform compatibility
    ///
    /// ## File Extensions
    /// - `.avi`
    ///
    /// ## Characteristics
    /// - Legacy format
    /// - Widely supported
    /// - Large file sizes
    /// - Limited compression
    ///
    /// ## Example Usage
    /// ```swift
    /// let aviData = try Data(contentsOf: aviURL)
    /// cloudStorage.upload(aviData, fileName: "video.avi", contentType: .avi)
    /// ```
    case avi = "video/x-msvideo"
}

/// A protocol that defines the contract for cloud storage operations.
///
/// `CloudStorage` provides a standardized interface for uploading data to cloud storage
/// services such as Amazon S3, Google Cloud Storage, or Azure Blob Storage. This protocol
/// abstracts the underlying storage implementation details and provides a consistent API
/// for file upload operations across different cloud providers.
///
/// ## Purpose
///
/// Cloud storage operations are essential for applications that need to store and
/// retrieve files from remote storage services. This protocol provides a unified
/// interface for upload operations, allowing applications to work with different
/// cloud storage providers without needing to know the specific implementation details.
///
/// ## Features
///
/// - **Unified API**: Consistent interface across different cloud storage providers
/// - **Async Operations**: Non-blocking upload operations with progress tracking
/// - **Content Type Support**: Proper MIME type handling for different file types
/// - **Upload Task Management**: Full control over upload lifecycle (pause, resume, cancel)
/// - **Progress Monitoring**: Real-time progress tracking during uploads
///
/// ## Supported Content Types
///
/// The protocol supports various content types through the `ContentType` enum:
/// - **Images**: JPEG, PNG, GIF, WebP
/// - **Videos**: MP4, MOV, AVI, WebM
/// - **Documents**: PDF, DOC, DOCX, TXT
/// - **Audio**: MP3, WAV, AAC, FLAC
/// - **Archives**: ZIP, RAR, 7Z
/// - **Custom**: Any MIME type for specialized use cases
///
/// ## Upload Task Management
///
/// Uploads return an `UploadTask` that provides full control over the upload process:
/// - **Progress Monitoring**: Track upload progress in real-time
/// - **State Management**: Monitor upload state (uploading, paused, completed, etc.)
/// - **Control Operations**: Pause, resume, or cancel uploads
/// - **Error Handling**: Handle upload failures gracefully
///
/// ## Example Usage
///
/// ```swift
/// // Upload an image
/// let imageData = UIImage(named: "photo")?.jpegData(compressionQuality: 0.8)
/// let uploadTask = cloudStorage.upload(
///     imageData!,
///     fileName: "profile-photo.jpg",
///     contentType: .image(.jpeg)
/// )
///
/// // Monitor upload progress
/// uploadTask.uploadProgress { progress in
///     print("Upload progress: \(Int(progress.fractionCompleted * 100))%")
/// }
///
/// // Control upload lifecycle
/// uploadTask.pause()  // Pause upload
/// uploadTask.resume() // Resume upload
/// uploadTask.cancel() // Cancel upload
///
/// // Upload a video with custom content type
/// let videoData = try Data(contentsOf: videoURL)
/// let videoUploadTask = cloudStorage.upload(
///     videoData,
///     fileName: "presentation.mp4",
///     contentType: .video(.mp4)
/// )
///
/// // Upload a document
/// let documentData = "Hello, World!".data(using: .utf8)!
/// let documentUploadTask = cloudStorage.upload(
///     documentData,
///     fileName: "readme.txt",
///     contentType: .text(.plain)
/// )
/// ```
///
public protocol CloudStorage: Sendable {
    /// Creates a new stream-based upload task to cloud storage.
    ///
    /// This method initializes and returns a `StreamUploadTask`, designed for uploading
    /// large files or continuous data streams in smaller, manageable chunks instead of
    /// sending them as a single in-memory `Data` object.
    ///
    /// This approach is particularly useful for:
    /// - Uploading videos or other large media files that may exceed memory limits.
    /// - Handling real-time generated content (e.g., live recording).
    /// - Ensuring resilience and efficiency in unstable network conditions.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the upload task, typically associated with the file
    ///     or resource being uploaded.
    ///   - contentType: The MIME type of the data being uploaded (e.g., `.videoMp4`, `.imageJpeg`).
    ///
    /// - Returns: A `StreamUploadTask` instance that enables incremental, chunk-based
    ///   uploading with full control over the streaming lifecycle.
    func streamUpload(with id: String, contentType: ContentType) -> any StreamUploadTask

    /// Uploads data to cloud storage and returns an upload task for monitoring and control.
    ///
    /// This method initiates an upload operation to the cloud storage service and returns
    /// an `UploadDataTask` that provides full control over the upload process. The upload
    /// task allows you to monitor progress, control the upload lifecycle, and handle
    /// completion or errors.
    ///
    /// - Parameters:
    ///   - data: The data to upload to cloud storage
    ///   - fileName: The name under which the file will be stored in cloud storage
    ///   - contentType: The MIME type of the data being uploaded
    /// - Returns: An `UploadDataTask` that provides control and monitoring capabilities for the upload operation
    func upload(_ data: Data, fileName: String, contentType: ContentType) -> any UploadDataTask
}
