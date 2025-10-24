//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "ViewController.h"

#import "CameraConfigurationViewController.h"
#import <TruvideoSdkCamera/TruvideoSdkCamera-Swift.h>
#import <QuickLook/QuickLook.h>

static NSString * const kMediaCellReuseIdentifier = @"MediaCell";
static const NSInteger kDefaultLimitedCount = 1;
static const NSInteger kDefaultGenericMediaCount = 3;
static const NSInteger kDefaultVideoDurationSeconds = 60;

@interface ViewController () <CameraConfigurationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic, strong) UIButton *presentCameraButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *configureButton;

@property (nonatomic) CameraMediaModeOption selectedMode;
@property (nonatomic, copy) NSNumber *mediaCount;
@property (nonatomic, copy) NSNumber *videoCount;
@property (nonatomic, copy) NSNumber *pictureCount;
@property (nonatomic, copy) NSNumber *videoDuration;
@property (nonatomic) TruvideoSdkCameraFlashMode flashMode;
@property (nonatomic) TruvideoSdkCameraLensFacing lensFacing;
@property (nonatomic) TruvideoSdkCameraImageFormat imageFormat;
@property (nonatomic, copy) NSArray<TruvideoSdkCameraMedia *> *capturedMedia;
@property (nonatomic, strong) NSURL *previewURL;
@property (nonatomic, strong) UILabel *emptyStateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Camera Obj-C";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.selectedMode = CameraMediaModeOptionVideosAndPictures;
    self.flashMode = TruvideoSdkCameraFlashModeOff;
    self.lensFacing = TruvideoSdkCameraLensFacingBack;
    self.imageFormat = TruvideoSdkCameraImageFormatJpeg;
    self.capturedMedia = @[];

    [self setupNavigation];
    [self setupUI];
}

#pragma mark - Setup

- (void)setupNavigation {
    self.configureButton = [[UIBarButtonItem alloc] initWithTitle:@"Configure"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(didTapConfigure)];
    self.navigationItem.rightBarButtonItem = self.configureButton;
}

- (void)setupUI {
    self.presentCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.presentCameraButton setTitle:@"Present Camera" forState:UIControlStateNormal];
    self.presentCameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.presentCameraButton addTarget:self action:@selector(didTapPresentCameraButton) forControlEvents:UIControlEventTouchUpInside];

    self.emptyStateLabel = [[UILabel alloc] init];
    self.emptyStateLabel.text = @"No media captured yet";
    self.emptyStateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.emptyStateLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyStateLabel.hidden = self.capturedMedia.count > 0;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundView = self.emptyStateLabel;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.presentCameraButton]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 12.0;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stackView];
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20.0],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24.0],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24.0],

        [self.tableView.topAnchor constraintEqualToAnchor:stackView.bottomAnchor constant:16.0],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - Helpers

- (TruvideoSdkCameraMediaMode *)activeMediaMode {
    NSNumber *mediaCount = self.mediaCount ?: @(kDefaultGenericMediaCount);
    NSNumber *videoCount = self.videoCount ?: @(kDefaultLimitedCount);
    NSNumber *pictureCount = self.pictureCount ?: @(kDefaultLimitedCount);
    NSNumber *videoDuration = self.videoDuration ?: @(kDefaultVideoDurationSeconds);

    switch (self.selectedMode) {
        case CameraMediaModeOptionVideosAndPictures:
            return [TruvideoSdkCameraMediaMode NSVideoAndPictureWithMediaCount:nil
                                                                   videoDuration:nil];

        case CameraMediaModeOptionGenericVideoOrPicture:
            return [TruvideoSdkCameraMediaMode NSVideoAndPictureWithMediaCount:mediaCount
                                                                   videoDuration:videoDuration];

        case CameraMediaModeOptionSpecificVideoAndPicture:
            return [TruvideoSdkCameraMediaMode NSVideoAndPictureWithVideoCount:videoCount
                                                                   pictureCount:pictureCount
                                                                   videoDuration:videoDuration];

        case CameraMediaModeOptionVideosOnly:
            return [TruvideoSdkCameraMediaMode NSVideoWithVideoCount:videoCount
                                                       videoDuration:videoDuration];

        case CameraMediaModeOptionPicturesOnly:
            return [TruvideoSdkCameraMediaMode NSPictureWithPictureCount:pictureCount];

        case CameraMediaModeOptionSingleVideo:
            return [TruvideoSdkCameraMediaMode NSSingleVideoWithVideoDuration:videoDuration];

        case CameraMediaModeOptionSinglePicture:
            return [TruvideoSdkCameraMediaMode NSSinglePicture];

        case CameraMediaModeOptionSingleVideoOrPicture:
            return [TruvideoSdkCameraMediaMode NSSingleVideoOrPictureWithVideoDuration:videoDuration];
    }
}

- (NSString *)currentModeDescription {
    switch (self.selectedMode) {
        case CameraMediaModeOptionVideosAndPictures:
            return @"Default video & picture";

        case CameraMediaModeOptionGenericVideoOrPicture:
            return [NSString stringWithFormat:@"Generic limit – media %@, duration %@",
                    self.mediaCount ?: @"∞",
                    self.videoDuration ?: @"∞"];

        case CameraMediaModeOptionSpecificVideoAndPicture:
            return [NSString stringWithFormat:@"Specific limit – videos %@, pictures %@, duration %@",
                    self.videoCount ?: @"∞",
                    self.pictureCount ?: @"∞",
                    self.videoDuration ?: @"∞"];

        case CameraMediaModeOptionVideosOnly:
            return [NSString stringWithFormat:@"Videos only – count %@, duration %@",
                    self.videoCount ?: @"∞",
                    self.videoDuration ?: @"∞"];

        case CameraMediaModeOptionPicturesOnly:
            return [NSString stringWithFormat:@"Pictures only – count %@",
                    self.pictureCount ?: @"∞"];

        case CameraMediaModeOptionSingleVideo:
            return [NSString stringWithFormat:@"Single video – duration %@",
                    self.videoDuration ?: @"∞"];

        case CameraMediaModeOptionSinglePicture:
            return @"Single picture";

        case CameraMediaModeOptionSingleVideoOrPicture:
            return [NSString stringWithFormat:@"Single video or picture – duration %@",
                    self.videoDuration ?: @"∞"];
    }
}

#pragma mark - Actions

- (void)didTapConfigure {
    CameraConfigurationViewController *controller = [[CameraConfigurationViewController alloc] init];
    controller.delegate = self;
    controller.selectedModeOption = self.selectedMode;
    controller.mediaCount = self.mediaCount;
    controller.videoCount = self.videoCount;
    controller.pictureCount = self.pictureCount;
    controller.videoDuration = self.videoDuration;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapPresentCameraButton {
    TruvideoSdkCameraMediaMode *mode = [self activeMediaMode];
    TruvideoSdkCameraConfiguration *configuration = [[TruvideoSdkCameraConfiguration alloc]
        initWithFlashMode:self.flashMode
               imageFormat:self.imageFormat
                lensFacing:self.lensFacing
                      mode:mode
                 outputPath:@""];

    __weak typeof(self) weakSelf = self;
    [self presentTruvideoSdkCameraViewWithPreset:configuration onComplete:^(TruvideoSdkCameraResult * _Nonnull result) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger mediaCount = result.media.count;
            if (mediaCount == 0) {
                strongSelf.capturedMedia = @[];
                strongSelf.emptyStateLabel.hidden = NO;
                [strongSelf.tableView reloadData];
                NSLog(@"[CameraObjectiveCExample] Completion block invoked with empty media array");
                return;
            }

            NSArray<TruvideoSdkCameraMedia *> *mediaItems = result.media;
            strongSelf.capturedMedia = mediaItems;
            strongSelf.emptyStateLabel.hidden = mediaItems.count > 0;
            [strongSelf.tableView reloadData];

            TruvideoSdkCameraMedia *firstMedia = mediaItems.firstObject;
            NSString *mediaDescription = [NSString stringWithFormat:@"%@ %@",
                                          firstMedia.type == TruvideoSdkCameraMediaTypeClip ? @"Video" : @"Photo",
                                          firstMedia.filePath ?: @"<missing path>"];

            NSLog(@"[CameraObjectiveCExample] Completion block received %lu item(s). First: %@", (unsigned long)mediaCount, mediaDescription);
        });
    }];
}

#pragma mark - CameraConfigurationViewControllerDelegate

- (void)cameraConfigurationViewController:(CameraConfigurationViewController *)controller
                       didFinishWithMode:(CameraMediaModeOption)mode
                               mediaCount:(NSNumber *)mediaCount
                               videoCount:(NSNumber *)videoCount
                              pictureCount:(NSNumber *)pictureCount
                             videoDuration:(NSNumber *)videoDuration
                                 flashMode:(TruvideoSdkCameraFlashMode)flashMode
                                lensFacing:(TruvideoSdkCameraLensFacing)lensFacing
                               imageFormat:(TruvideoSdkCameraImageFormat)imageFormat {

    self.selectedMode = mode;
    self.mediaCount = mediaCount;
    self.videoCount = videoCount;
    self.pictureCount = pictureCount;
    self.videoDuration = videoDuration;
    self.flashMode = flashMode;
    self.lensFacing = lensFacing;
    self.imageFormat = imageFormat;

    NSLog(@"[CameraObjectiveCExample] Delegate updated configuration. Mode: %ld, Flash: %ld, Lens: %ld, Format: %ld",
          (long)mode,
          (long)flashMode,
          (long)lensFacing,
          (long)imageFormat);

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.capturedMedia.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMediaCellReuseIdentifier];
    }
    TruvideoSdkCameraMedia *media = self.capturedMedia[indexPath.row];

    NSString *filename = media.filePath.lastPathComponent ?: media.filePath ?: @"<unknown>";
    NSString *type = media.type == TruvideoSdkCameraMediaTypeClip ? @"Video" : @"Photo";
    NSString *detail;
    if (media.type == TruvideoSdkCameraMediaTypeClip) {
        detail = [NSString stringWithFormat:@"%@ • %.1f s", type, media.duration / 1000.0];
        cell.imageView.image = [UIImage systemImageNamed:@"video"];
        cell.imageView.tintColor = [UIColor systemBlueColor];
    } else {
        detail = type;
        cell.imageView.image = [UIImage systemImageNamed:@"photo"];
        cell.imageView.tintColor = [UIColor systemGreenColor];
    }

    cell.textLabel.text = filename;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TruvideoSdkCameraMedia *media = self.capturedMedia[indexPath.row];
    NSString *path = media.filePath;
    if (path.length == 0) {
        return;
    }

    NSURL *url = [NSURL fileURLWithPath:path];
    self.previewURL = url;

    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    [self presentViewController:previewController animated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.previewURL ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewURL;
}

#pragma mark - QLPreviewControllerDelegate

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    self.previewURL = nil;
}

@end
