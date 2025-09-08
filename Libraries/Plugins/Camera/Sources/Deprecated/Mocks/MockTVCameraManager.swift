//
//  MockTVCameraManager.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import AVKit
import Combine
import Foundation

class MockTVCameraManager: TVCameraManagerProtocol {

    let previewLayer: AVCaptureVideoPreviewLayer = .init()

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        isRecordingSubject.eraseToAnyPublisher()
    }

    private let isVideoPausedSubject = CurrentValueSubject<Bool, Never>(false)
    var isVideoPausedPublisher: AnyPublisher<Bool, Never> {
        isVideoPausedSubject.eraseToAnyPublisher()
    }

    private let photosSubject = PassthroughSubject<TruVideoPhoto, Never>()
    var photosPublisher: AnyPublisher<TruVideoPhoto, Never> {
        photosSubject
            .eraseToAnyPublisher()
    }

    private let videosSubject = PassthroughSubject<TruVideoClip, Never>()
    var videosPublisher: AnyPublisher<TruVideoClip, Never> {
        videosSubject
            .eraseToAnyPublisher()
    }

    private let torchSubject = PassthroughSubject<TorchStatus, Never>()
    var torchPublisher: AnyPublisher<TorchStatus, Never> {
        torchSubject
            .eraseToAnyPublisher()
    }

    private let recordedDurationSubject = PassthroughSubject<Double, Never>()
    var recordedDurationPublisher: AnyPublisher<Double, Never> {
        recordedDurationSubject
            .eraseToAnyPublisher()
    }

    private let flipCameraSubject = PassthroughSubject<Void, Never>()
    var flipCameraPublisher: AnyPublisher<Void, Never> {
        flipCameraSubject
            .eraseToAnyPublisher()
    }

    private let simulatePauseSubject = PassthroughSubject<Bool, Never>()
    var simulatePausePublisher: AnyPublisher<Bool, Never> {
        simulatePauseSubject
            .eraseToAnyPublisher()
    }

    private let showLoaderSubject = PassthroughSubject<Bool, Never>()
    var showLoaderPublisher: AnyPublisher<Bool, Never> {
        showLoaderSubject
            .eraseToAnyPublisher()
    }

    private let permissionStatusSubject = CurrentValueSubject<Bool, Never>(false)
    var permissionStatusPublisher: AnyPublisher<Bool, Never> {
        permissionStatusSubject
            .eraseToAnyPublisher()
    }

    var isFlashAvailable: Bool = true

    func getCurrentPermissionStatus() -> Bool {
        false
    }

    init(preset: TruvideoSdkCameraConfiguration) {

    }

    func toggleRecord() {

    }

    func takePhoto() {

    }

    func pauseRecord() {

    }

    func flipCamera() {

    }

    func changeResolution(to resolution: TruvideoSdkCameraResolutionFormat) {

    }

    func toggleFlash() {

    }

    func configureZoomFactor(to zoomFactor: CGFloat) {

    }

    func focus(at point: CGPoint) {

    }

    @discardableResult
    func updateVideoPreviewOrientation(_ previewOrientation: UIDeviceOrientation) -> Bool {
        true
    }

    @discardableResult
    func updateVideoConnectionOrientation(_ physicalOrientation: UIDeviceOrientation) -> Bool {
        true
    }
}
