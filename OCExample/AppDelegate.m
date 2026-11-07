#import "AppDelegate.h"
#import "MenuViewController.h"
#import <AVFAudio/AVFAudio.h>
#import <DZDramaSDK/DZDramaSDK-Swift.h>
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [DZDramaSDKManager.shared navigationControllerWithRootViewController:[MenuViewController new]];
    [self.window makeKeyAndVisible];
    if (!NSProcessInfo.processInfo.environment[@"XCTestConfigurationFilePath"]) {
        DZDramaConfiguration *configuration = [DZDramaConfiguration new];
        configuration.appKey = [NSBundle.mainBundle objectForInfoDictionaryKey:@"DZDramaAppKey"] ?: @"";
        if (configuration.appKey.length > 0) {
            [DZDramaSDKManager.shared initializeWithConfiguration:configuration completion:^(NSError *error) {
                NSLog(@"DZDramaSDK 初始化: %@", error ?: @"成功");
            }];
        } else {
            NSLog(@"请先在宿主 Info.plist 配置 DZDramaAppKey 和合作方授权信息");
        }
    }
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:nil];
    return YES;
}
@end
