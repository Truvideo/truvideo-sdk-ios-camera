//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "CameraConfigurationViewController.h"

#import <TruvideoSdkCamera/TruvideoSdkCamera-Swift.h>
#import "TextFieldTableViewCell.h"

typedef NS_ENUM(NSInteger, CameraConfigurationSection) {
    CameraConfigurationSectionModes,
    CameraConfigurationSectionInputs,
    CameraConfigurationSectionCamera,
    CameraConfigurationSectionCount
};

static NSString * const kModeCellReuseIdentifier = @"ModeCell";
static NSString * const kTextFieldCellReuseIdentifier = @"TextFieldCell";
static NSString * const kOptionCellReuseIdentifier = @"OptionCell";
static const NSInteger kDefaultLimitedCount = 1;
static const NSInteger kDefaultGenericMediaCount = 3;
static const NSInteger kDefaultVideoDurationSeconds = 60;

@interface CameraConfigurationViewController ()

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *modeOptions;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *flashOptions;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *lensOptions;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *imageFormatOptions;

@end

@implementation CameraConfigurationViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _selectedModeOption = CameraMediaModeOptionVideosAndPictures;
        _flashMode = TruvideoSdkCameraFlashModeOff;
        _lensFacing = TruvideoSdkCameraLensFacingBack;
        _imageFormat = TruvideoSdkCameraImageFormatJpeg;
        [self setupModeOptions];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Camera Configuration";

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kModeCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kOptionCellReuseIdentifier];
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:kTextFieldCellReuseIdentifier];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(didTapConfirm)];
}

- (void)setupModeOptions {
    self.modeOptions = @[
        @{ @"title": @"Video and Picture", @"subtitle": @"Sensible defaults" },
        @{ @"title": @"Video and Picture (Generic Limit)", @"subtitle": @"Configure media count & duration" },
        @{ @"title": @"Video and Picture (Specific Limit)", @"subtitle": @"Configure video/picture counts" },
        @{ @"title": @"Videos Only", @"subtitle": @"Configure video count & duration" },
        @{ @"title": @"Pictures Only", @"subtitle": @"Configure picture count" },
        @{ @"title": @"Single Video", @"subtitle": @"Enforce maximum duration" },
        @{ @"title": @"Single Picture", @"subtitle": @"Capture one photo" },
        @{ @"title": @"Single Video or Picture", @"subtitle": @"Single capture with duration" }
    ];

    self.flashOptions = @[
        @{ @"title": @"Flash Off", @"value": @(TruvideoSdkCameraFlashModeOff) },
        @{ @"title": @"Flash On", @"value": @(TruvideoSdkCameraFlashModeOn) }
    ];

    self.lensOptions = @[
        @{ @"title": @"Back Camera", @"value": @(TruvideoSdkCameraLensFacingBack) },
        @{ @"title": @"Front Camera", @"value": @(TruvideoSdkCameraLensFacingFront) }
    ];

    self.imageFormatOptions = @[
        @{ @"title": @"JPEG", @"value": @(TruvideoSdkCameraImageFormatJpeg) },
        @{ @"title": @"PNG", @"value": @(TruvideoSdkCameraImageFormatPng) }
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CameraConfigurationSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == CameraConfigurationSectionModes) {
        return self.modeOptions.count;
    }

    if (section == CameraConfigurationSectionCamera) {
        return 3;
    }

    switch (self.selectedModeOption) {
        case CameraMediaModeOptionVideosAndPictures:
        case CameraMediaModeOptionSinglePicture:
            return 0;

        case CameraMediaModeOptionGenericVideoOrPicture:
            return 2;

        case CameraMediaModeOptionSpecificVideoAndPicture:
            return 3;

        case CameraMediaModeOptionVideosOnly:
            return 2;

        case CameraMediaModeOptionPicturesOnly:
            return 1;

        case CameraMediaModeOptionSingleVideo:
            return 1;

        case CameraMediaModeOptionSingleVideoOrPicture:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == CameraConfigurationSectionModes) {
        return @"Media Modes";
    }

    if (section == CameraConfigurationSectionInputs) {
        return @"Limits";
    }

    return @"Camera";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == CameraConfigurationSectionModes) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kModeCellReuseIdentifier forIndexPath:indexPath];
        NSDictionary<NSString *, NSString *> *option = self.modeOptions[indexPath.row];
        cell.textLabel.text = option[@"title"];
        cell.detailTextLabel.text = option[@"subtitle"];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = (indexPath.row == self.selectedModeOption) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.textLabel.numberOfLines = 1;
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        return cell;
    }

    if (indexPath.section == CameraConfigurationSectionCamera) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOptionCellReuseIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        switch (indexPath.row) {
            case 0: { // Flash
                NSDictionary *selected = [self optionMatchingValue:@(self.flashMode) inArray:self.flashOptions];
                cell.textLabel.text = [NSString stringWithFormat:@"Flash: %@", selected[@"title"]];
                break;
            }

            case 1: { // Lens
                NSDictionary *selected = [self optionMatchingValue:@(self.lensFacing) inArray:self.lensOptions];
                cell.textLabel.text = [NSString stringWithFormat:@"Lens: %@", selected[@"title"]];
                break;
            }

            case 2: { // Image format
                NSDictionary *selected = [self optionMatchingValue:@(self.imageFormat) inArray:self.imageFormatOptions];
                cell.textLabel.text = [NSString stringWithFormat:@"Image Format: %@", selected[@"title"]];
                break;
            }

            default:
                break;
        }

        return cell;
    }

    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellReuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (self.selectedModeOption) {
        case CameraMediaModeOptionGenericVideoOrPicture: {
            if (indexPath.row == 0) {
                cell.textField.placeholder = @"Max media count";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.mediaCount.stringValue;
            } else {
                cell.textField.placeholder = @"Max video duration (seconds)";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.videoDuration.stringValue;
            }
            break;
        }

        case CameraMediaModeOptionSpecificVideoAndPicture: {
            if (indexPath.row == 0) {
                cell.textField.placeholder = @"Max video count";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.videoCount.stringValue;
            } else if (indexPath.row == 1) {
                cell.textField.placeholder = @"Max picture count";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.pictureCount.stringValue;
            } else {
                cell.textField.placeholder = @"Max video duration (seconds)";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.videoDuration.stringValue;
            }
            break;
        }

        case CameraMediaModeOptionVideosOnly: {
            if (indexPath.row == 0) {
                cell.textField.placeholder = @"Max video count";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.videoCount.stringValue;
            } else {
                cell.textField.placeholder = @"Max video duration (seconds)";
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                cell.textField.text = self.videoDuration.stringValue;
            }
            break;
        }

        case CameraMediaModeOptionPicturesOnly: {
            cell.textField.placeholder = @"Max picture count";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.text = self.pictureCount.stringValue;
            break;
        }

        case CameraMediaModeOptionSingleVideo: {
            cell.textField.placeholder = @"Max video duration (seconds)";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.text = self.videoDuration.stringValue;
            break;
        }

        case CameraMediaModeOptionSingleVideoOrPicture: {
            cell.textField.placeholder = @"Max video duration (seconds)";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.text = self.videoDuration.stringValue;
            break;
        }

        case CameraMediaModeOptionVideosAndPictures:
        case CameraMediaModeOptionSinglePicture:
            break;
    }

    cell.textField.tag = [self inputTagForIndexPath:indexPath];
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == CameraConfigurationSectionModes) {
        self.selectedModeOption = indexPath.row;
        self.mediaCount = nil;
        self.videoCount = nil;
        self.pictureCount = nil;
        self.videoDuration = nil;
        [tableView reloadData];
        return;
    }

    if (indexPath.section == CameraConfigurationSectionCamera) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSIndexPath *reloadIndexPath = indexPath;
        UIAlertController *controller = nil;

        if (indexPath.row == 0) {
            controller = [self optionSheetWithTitle:@"Flash Mode"
                                            options:self.flashOptions
                                      currentValue:@(self.flashMode)
                                           handler:^(NSNumber *value) {
                                               self.flashMode = value.integerValue;
                                               [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath]
                                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }];
        } else if (indexPath.row == 1) {
            controller = [self optionSheetWithTitle:@"Lens"
                                            options:self.lensOptions
                                      currentValue:@(self.lensFacing)
                                           handler:^(NSNumber *value) {
                                               self.lensFacing = value.integerValue;
                                               [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath]
                                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }];
        } else if (indexPath.row == 2) {
            controller = [self optionSheetWithTitle:@"Image Format"
                                            options:self.imageFormatOptions
                                      currentValue:@(self.imageFormat)
                                           handler:^(NSNumber *value) {
                                               self.imageFormat = value.integerValue;
                                               [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath]
                                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }];
        }

        if (controller) {
            UIPopoverPresentationController *popover = controller.popoverPresentationController;
            if (popover) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    popover.sourceView = cell;
                    popover.sourceRect = cell.bounds;
                } else {
                    popover.sourceView = self.view;
                    popover.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 1, 1);
                }
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [self presentViewController:controller animated:YES completion:nil];
        }
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

#pragma mark - Actions

- (void)textFieldDidChange:(UITextField *)textField {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSNumber *value = [formatter numberFromString:textField.text];
    switch (textField.tag) {
        case 0:
            self.mediaCount = value;
            break;

        case 1:
            self.videoCount = value;
            break;

        case 2:
            self.pictureCount = value;
            break;

        case 3:
            self.videoDuration = value;
            break;

        default:
            break;
    }
}

- (NSInteger)inputTagForIndexPath:(NSIndexPath *)indexPath {
    switch (self.selectedModeOption) {
        case CameraMediaModeOptionGenericVideoOrPicture:
            return indexPath.row == 0 ? 0 : 3;

        case CameraMediaModeOptionSpecificVideoAndPicture:
            if (indexPath.row == 0) {
                return 1; // video count
            }
            if (indexPath.row == 1) {
                return 2; // picture count
            }
            return 3; // video duration

        case CameraMediaModeOptionVideosOnly:
            return indexPath.row == 0 ? 1 : 3;

        case CameraMediaModeOptionPicturesOnly:
            return 2;

        case CameraMediaModeOptionSingleVideo:
        case CameraMediaModeOptionSingleVideoOrPicture:
            return 3;

        case CameraMediaModeOptionVideosAndPictures:
        case CameraMediaModeOptionSinglePicture:
            return 0;
    }
}

- (void)didTapConfirm {
    SEL selector = @selector(cameraConfigurationViewController:didFinishWithMode:mediaCount:videoCount:pictureCount:videoDuration:flashMode:lensFacing:imageFormat:);

    if ([self.delegate respondsToSelector:selector]) {
        NSNumber *media = self.mediaCount ?: @(kDefaultGenericMediaCount);
        NSNumber *video = self.videoCount ?: @(kDefaultLimitedCount);
        NSNumber *picture = self.pictureCount ?: @(kDefaultLimitedCount);
        NSNumber *duration = self.videoDuration ?: @(kDefaultVideoDurationSeconds);
        [self.delegate cameraConfigurationViewController:self
                                      didFinishWithMode:self.selectedModeOption
                                             mediaCount:media
                                             videoCount:video
                                            pictureCount:picture
                                           videoDuration:duration
                                               flashMode:self.flashMode
                                              lensFacing:self.lensFacing
                                             imageFormat:self.imageFormat];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helpers

- (NSDictionary<NSString *, id> *)optionMatchingValue:(NSNumber *)value inArray:(NSArray<NSDictionary<NSString *, id> *> *)array {
    for (NSDictionary *option in array) {
        if ([option[@"value"] isEqual:value]) {
            return option;
        }
    }
    return array.firstObject;
}

- (UIAlertController *)optionSheetWithTitle:(NSString *)title
                                     options:(NSArray<NSDictionary<NSString *, id> *> *)options
                                  currentValue:(NSNumber *)currentValue
                                       handler:(void (^)(NSNumber *value))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *option in options) {
        NSNumber *value = option[@"value"];
        NSString *optionTitle = option[@"title"];

        UIAlertAction *action = [UIAlertAction actionWithTitle:optionTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull __unused action) {
                                                           handler(value);
                                                       }];
        if ([value isEqual:currentValue]) {
            action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ ✓", optionTitle]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull __unused selected) {
                                                handler(value);
                                            }];
        }
        [alert addAction:action];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

@end
