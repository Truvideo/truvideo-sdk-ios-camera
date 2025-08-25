//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

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
/// ## Error Handling
///
/// Upload operations may fail for various reasons:
/// - **Network connectivity issues**: Unable to reach cloud storage service
/// - **Authentication failures**: Invalid credentials or expired tokens
/// - **Storage quota exceeded**: Insufficient storage space
/// - **Invalid content type**: Unsupported file format
/// - **File size limits**: File exceeds maximum allowed size
///
/// ## Thread Safety
///
/// Implementations should be thread-safe and handle concurrent upload operations
/// appropriately. Multiple uploads can be performed simultaneously without
/// interfering with each other.
///
/// ## Performance Considerations
///
/// - **Large Files**: For large files, consider using multipart uploads
/// - **Concurrent Uploads**: Multiple uploads can run simultaneously
/// - **Progress Updates**: Progress callbacks may be frequent, handle efficiently
/// - **Memory Usage**: Large files may consume significant memory during upload
///
/// ## Security Considerations
///
/// - **Authentication**: Ensure proper authentication with cloud storage service
/// - **Authorization**: Verify appropriate permissions for upload operations
/// - **Data Encryption**: Consider encrypting sensitive data before upload
/// - **Access Control**: Implement proper access controls for uploaded files
public protocol CloudStorage: Sendable {
    
    /// Uploads data to cloud storage and returns an upload task for monitoring and control.
    ///
    /// This method initiates an upload operation to the cloud storage service and returns
    /// an `UploadTask` that provides full control over the upload process. The upload
    /// task allows you to monitor progress, control the upload lifecycle, and handle
    /// completion or errors.
    ///
    /// ## Upload Process
    ///
    /// The upload process typically involves:
    /// 1. **Validation**: Verify data, file name, and content type
    /// 2. **Authentication**: Authenticate with cloud storage service
    /// 3. **Upload Initiation**: Start the upload operation
    /// 4. **Progress Tracking**: Monitor upload progress in real-time
    /// 5. **Completion**: Handle successful completion or errors
    ///
    /// ## File Naming
    ///
    /// The `fileName` parameter determines how the file will be stored in cloud storage:
    /// - **Unique Names**: Use unique identifiers to avoid conflicts
    /// - **Path Structure**: Include directory paths for organization
    /// - **File Extensions**: Ensure proper file extensions match content type
    /// - **Special Characters**: Avoid special characters that may cause issues
    ///
    /// ## Content Type Handling
    ///
    /// The `contentType` parameter ensures proper handling of the uploaded data:
    /// - **MIME Type**: Sets the correct MIME type for the file
    /// - **Browser Compatibility**: Ensures proper display in web browsers
    /// - **Storage Optimization**: May enable storage optimizations
    /// - **Access Control**: May affect access permissions
    ///
    /// ## Upload Task Features
    ///
    /// The returned `UploadTask` provides:
    /// - **Progress Monitoring**: Track upload progress with callbacks
    /// - **State Management**: Monitor upload state (uploading, paused, completed, etc.)
    /// - **Control Operations**: Pause, resume, or cancel uploads
    /// - **Error Handling**: Handle upload failures and retry logic
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Upload an image with progress monitoring
    /// let imageData = UIImage(named: "photo")?.jpegData(compressionQuality: 0.8)
    /// let uploadTask = cloudStorage.upload(
    ///     imageData!,
    ///     fileName: "users/123/profile-photo.jpg",
    ///     contentType: .image(.jpeg)
    /// )
    ///
    /// // Monitor progress
    /// uploadTask.uploadProgress { progress in
    ///     DispatchQueue.main.async {
    ///         self.progressView.progress = Float(progress.fractionCompleted)
    ///         self.statusLabel.text = "Uploading... \(Int(progress.fractionCompleted * 100))%"
    ///     }
    /// }
    ///
    /// // Upload a video with custom content type
    /// let videoData = try Data(contentsOf: videoURL)
    /// let videoUploadTask = cloudStorage.upload(
    ///     videoData,
    ///     fileName: "videos/presentation-\(Date().timeIntervalSince1970).mp4",
    ///     contentType: .video(.mp4)
    /// )
    ///
    /// // Upload a document
    /// let documentData = "Document content".data(using: .utf8)!
    /// let documentUploadTask = cloudStorage.upload(
    ///     documentData,
    ///     fileName: "documents/report.txt",
    ///     contentType: .text(.plain)
    /// )
    /// ```
    ///
    /// ## Error Scenarios
    ///
    /// ```swift
    /// let uploadTask = cloudStorage.upload(data, fileName: "file.txt", contentType: .text(.plain))
    ///
    /// // Handle different upload states
    /// switch uploadTask.state {
    /// case .uploading:
    ///     print("Upload in progress...")
    /// case .completed:
    ///     print("Upload completed successfully")
    /// case .failed:
    ///     print("Upload failed")
    /// case .cancelled:
    ///     print("Upload was cancelled")
    /// case .paused:
    ///     print("Upload is paused")
    /// case .ready:
    ///     print("Upload ready to start")
    /// }
    /// ```
    ///
    /// ## Performance Considerations
    ///
    /// - **Large Files**: For files larger than 5MB, consider using multipart uploads
    /// - **Concurrent Uploads**: Multiple uploads can run simultaneously
    /// - **Memory Usage**: Large files may consume significant memory during upload
    /// - **Network Conditions**: Upload speed depends on network connectivity
    ///
    /// ## Security Best Practices
    ///
    /// - **File Validation**: Validate file content before upload
    /// - **Access Control**: Implement proper access controls
    /// - **Encryption**: Consider encrypting sensitive data
    /// - **Audit Logging**: Log upload operations for security auditing
    ///
    /// - Parameters:
    ///   - data: The data to upload to cloud storage
    ///   - fileName: The name under which the file will be stored in cloud storage
    ///   - contentType: The MIME type of the data being uploaded
    /// - Returns: An `UploadTask` that provides control and monitoring capabilities for the upload operation
    func upload(_ data: Data, fileName: String, contentType: ContentType) -> any UploadTask
}
