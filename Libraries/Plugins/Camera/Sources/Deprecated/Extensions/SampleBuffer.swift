//
//  SampleBuffer.swift
//
//  Created by TruVideo on 6/14/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import CoreMedia
import UIKit

extension CMSampleBuffer {
    /// Extracts the metadata dictionary from a `CMSampleBuffer`.
    ///  (ie EXIF: Aperture, Brightness, Exposure, FocalLength, etc)
    ///
    /// - Parameter sampleBuffer: sample buffer to be processed
    /// - Returns: metadata dictionary from the provided sample buffer
    var metadata: [String: Any]? {
        guard
            let metadata = CMCopyDictionaryOfAttachments(
                allocator: kCFAllocatorDefault,
                target: self,
                attachmentMode: kCMAttachmentMode_ShouldPropagate
            )
        else {
            return nil
        }

        return metadata as? [String: Any]
    }
}
