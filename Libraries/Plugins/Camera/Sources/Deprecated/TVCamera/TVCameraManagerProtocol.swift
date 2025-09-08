//
//  TVCameraManagerProtocol.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import AVKit
import Combine
import Foundation

// - MARK: Camera Manager Interface
protocol TVCameraManagerProtocol {
    var previewLayer: AVCaptureVideoPreviewLayer { get }

    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }

    var isVideoPausedPublisher: AnyPublisher<Bool, Never> { get }

    var photosPublisher: AnyPublisher<TruVideoPhoto, Never> { get }

    var videosPublisher: AnyPublisher<TruVideoClip, Never> { get }

    var torchPublisher: AnyPublisher<TorchStatus, Never> { get }

    var recordedDurationPublisher: AnyPublisher<Double, Never> { get }

    var flipCameraPublisher: AnyPublisher<Void, Never> { get }

    var showLoaderPublisher: AnyPublisher<Bool, Never> { get }

    var permissionStatusPublisher: AnyPublisher<Bool, Never> { get }

    var isFlashAvailable: Bool { get }

    func getCurrentPermissionStatus() -> Bool

    func toggleRecord()

    func takePhoto()

    func pauseRecord()

    func flipCamera()

    func changeResolution(to resolution: TruvideoSdkCameraResolutionFormat)

    func toggleFlash()

    func configureZoomFactor(to zoomFactor: CGFloat)

    func focus(at point: CGPoint)

    @discardableResult
    func updateVideoPreviewOrientation(_ previewOrientation: UIDeviceOrientation) -> Bool

    @discardableResult
    func updateVideoConnectionOrientation(_ physicalOrientation: UIDeviceOrientation) -> Bool
}
