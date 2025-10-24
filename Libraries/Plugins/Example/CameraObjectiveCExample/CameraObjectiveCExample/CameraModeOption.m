//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "CameraModeOption.h"

@interface CameraModeOption ()

@property (nonatomic) CameraModeOptionType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;

@end

@implementation CameraModeOption

- (instancetype)initWithType:(CameraModeOptionType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        _type = type;
        _title = [title copy];
        _subtitle = [subtitle copy];
    }
    return self;
}

@end
