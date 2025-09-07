//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "CameraLibraryRegistry.h"
#import "TruvideoSdkCamera/TruvideoSdkCamera-Swift.h"

@implementation CameraLibraryRegistry

+ (void)load {
    [SDKCameraLibrary register];
}

@end
