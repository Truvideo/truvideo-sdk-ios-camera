//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CameraModeOptionType) {
    CameraModeOptionTypeVideosAndPictures,
    CameraModeOptionTypeGenericVideoOrPicture,
    CameraModeOptionTypeSpecificVideoAndPicture,
    CameraModeOptionTypeSingleVideo,
    CameraModeOptionTypeSinglePicture,
    CameraModeOptionTypeSingleVideoOrPicture,
    CameraModeOptionTypeVideosOnly,
    CameraModeOptionTypePicturesOnly
};

NS_ASSUME_NONNULL_BEGIN

@interface CameraModeOption : NSObject

@property (nonatomic, readonly) CameraModeOptionType type;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

- (instancetype)initWithType:(CameraModeOptionType)type title:(NSString *)title subtitle:(NSString * _Nullable)subtitle;

@end

NS_ASSUME_NONNULL_END
