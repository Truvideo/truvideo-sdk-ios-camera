//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "AppDelegate.h"

#import "CameraObjectiveCExample-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ObjectiveCSampleAuthenticator configureAndAuthenticateWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"[CameraObjectiveCExample] Authentication failed: %@", error.localizedDescription);
        }
    }];
    return YES;
}

@end
