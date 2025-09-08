//
//  CameraManager.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/6/24.
//

import AVFoundation
import Foundation

final class CameraManager {
    private let className = String(describing: CameraManager.self)

    func getAvailableResolutions(
        for position: AVCaptureDevice.Position,
        isHighPhotoQualitySupported: Bool = false
    ) -> [TruvideoSdkCameraResolutionFormat] {
        guard
            let camera = AVCaptureDevice.primaryVideoDevice(for: position)
        else {
            return []
        }
        return camera.formats.compactMap({ format in
            dprint(className, "Resolution format: \(format)")

            let videoDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            dprint(className, "video dimensions: \(videoDimensions.width)x\(videoDimensions.height)")

            guard format.isVideoStabilizationModeSupported(.auto) else {
                dprint(className, "video stabilization is not [SUPPORTED]")
                return nil
            }

            if isHighPhotoQualitySupported, format.isHighPhotoQualitySupported {
                let photoDimensions = format.highResolutionStillImageDimensions
                dprint(className, "high photo dimensions: \(photoDimensions.width)x\(photoDimensions.height)")
                return TruvideoSdkCameraResolutionFormat(
                    width: videoDimensions.width,
                    height: videoDimensions.height,
                    highResolutionPhotoWidth: photoDimensions.width,
                    highResolutionPhotoHeight: photoDimensions.height,
                    type: position == .back ? .back : .front,
                    format: format
                )
            } else {
                dprint(className, "does not support high photos resolution")
                dprint(
                    className,
                    "video stabilization is [SUPPORTED] for \(videoDimensions.width)x\(videoDimensions.height)"
                )
                return TruvideoSdkCameraResolutionFormat(
                    width: videoDimensions.width,
                    height: videoDimensions.height,
                    type: position == .back ? .back : .front,
                    format: format
                )
            }
        })
        .removeDuplicates()
        .sorted()
        .filterStandardResolutions()
    }

    func isTapToFocusEnabled(for position: AVCaptureDevice.Position) -> Bool {
        guard
            let camera = AVCaptureDevice.primaryVideoDevice(for: position)
        else {
            return false
        }

        if camera.isFocusPointOfInterestSupported && camera.isFocusModeSupported(.autoFocus) {
            return true
        }

        if camera.isExposurePointOfInterestSupported && camera.isExposureModeSupported(.autoExpose) {
            return true
        }

        return false
    }

    func filterValidResolutions(
        from resolutions: [TruvideoSdkCameraResolution],
        using allResolutions: [TruvideoSdkCameraResolutionFormat]
    ) -> [TruvideoSdkCameraResolutionFormat] {
        var validResolutions = [TruvideoSdkCameraResolutionFormat]()

        for resolution in resolutions {
            for res in allResolutions {
                if resolution == res {
                    validResolutions.append(res)
                    continue
                }
            }
        }

        return validResolutions.isEmpty ? allResolutions : validResolutions
    }

    func getResolutionFormat(
        from resolution: TruvideoSdkCameraResolution?,
        using allResolutions: [TruvideoSdkCameraResolutionFormat]
    ) -> TruvideoSdkCameraResolutionFormat? {
        guard let resolution else {
            return allResolutions.first
        }

        for res in allResolutions {
            if resolution == res {
                return res
            }
        }
        return allResolutions.first
    }
}

extension [TruvideoSdkCameraResolutionFormat] {
    fileprivate func removeDuplicates() -> [TruvideoSdkCameraResolutionFormat] {
        var uniqueResolutions: [TruvideoSdkCameraResolutionFormat] = []

        for uniqueResolution in self {
            if !uniqueResolutions.contains(where: {
                $0.width == uniqueResolution.width && $0.height == uniqueResolution.height
            }) {
                uniqueResolutions.append(uniqueResolution)
            }
        }

        return uniqueResolutions
    }
}
