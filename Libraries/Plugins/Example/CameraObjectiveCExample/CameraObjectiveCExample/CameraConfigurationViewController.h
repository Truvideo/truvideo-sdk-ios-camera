//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TruvideoSdkCamera/TruvideoSdkCamera-Swift.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CameraMediaModeOption) {
    CameraMediaModeOptionVideosAndPictures,
    CameraMediaModeOptionGenericVideoOrPicture,
    CameraMediaModeOptionSpecificVideoAndPicture,
    CameraMediaModeOptionVideosOnly,
    CameraMediaModeOptionPicturesOnly,
    CameraMediaModeOptionSingleVideo,
    CameraMediaModeOptionSinglePicture,
    CameraMediaModeOptionSingleVideoOrPicture
};

@protocol CameraConfigurationViewControllerDelegate;

@interface CameraConfigurationViewController : UITableViewController

@property (nonatomic, weak) id<CameraConfigurationViewControllerDelegate> delegate;
@property (nonatomic) CameraMediaModeOption selectedModeOption;
@property (nonatomic, copy, nullable) NSNumber *mediaCount;
@property (nonatomic, copy, nullable) NSNumber *videoCount;
@property (nonatomic, copy, nullable) NSNumber *pictureCount;
@property (nonatomic, copy, nullable) NSNumber *videoDuration;
@property (nonatomic) TruvideoSdkCameraFlashMode flashMode;
@property (nonatomic) TruvideoSdkCameraLensFacing lensFacing;
@property (nonatomic) TruvideoSdkCameraImageFormat imageFormat;

@end

@protocol CameraConfigurationViewControllerDelegate <NSObject>

- (void)cameraConfigurationViewController:(CameraConfigurationViewController *)controller
                       didFinishWithMode:(CameraMediaModeOption)mode
                               mediaCount:(NSNumber * _Nullable)mediaCount
                               videoCount:(NSNumber * _Nullable)videoCount
                              pictureCount:(NSNumber * _Nullable)pictureCount
                             videoDuration:(NSNumber * _Nullable)videoDuration
                                 flashMode:(TruvideoSdkCameraFlashMode)flashMode
                                lensFacing:(TruvideoSdkCameraLensFacing)lensFacing
                               imageFormat:(TruvideoSdkCameraImageFormat)imageFormat;

@end

NS_ASSUME_NONNULL_END
