#import <XCTest/XCTest.h>
#import <DZDramaSDK/DZDramaSDK-Swift.h>
#import <DZDramaSDK/UIViewController+DZExtend.h>
@interface DZDramaSDKIntegrationTests : XCTestCase
@end
@implementation DZDramaSDKIntegrationTests
- (void)testBinaryPageFactoriesAndNavigation {
    XCTAssertEqualObjects(DZDramaSDKManager.sdkVersion, @"1.0.0");
    NSArray *expected = @[@"DZDramaRecommendViewController", @"DZTheaterMainViewController", @"DZSearchOpearViewController", @"DZLibraryViewController"];
    for (NSInteger index = 0; index < expected.count; index++) {
        UIViewController *page = [DZDramaSDKManager.shared viewControllerForPage:(DZDramaPage)index];
        XCTAssertNotNil(page);
        XCTAssertTrue([NSStringFromClass(page.class) hasSuffix:expected[index]]);
        UINavigationController *navigation = [DZDramaSDKManager.shared navigationControllerWithRootViewController:page];
        XCTAssertEqual(navigation.topViewController, page);
    }
    XCTAssertNotNil([DZDramaSDKManager.shared detailViewControllerWithBookID:@"fixture" chapterIndex:1 playStartPosition:0]);
}
- (void)testCompiledResourcesAreLoadedFromSDKBundle {
    NSBundle *bundle = DZDramaSDKManager.resourceBundle;
    XCTAssertEqualObjects(bundle.bundleURL.lastPathComponent, @"DZDramaSDKResources.bundle");
    XCTAssertNotNil([UIImage imageNamed:@"player_back" inBundle:bundle compatibleWithTraitCollection:nil]);
    XCTAssertNotNil([UIImage imageNamed:@"dz_episode_locked" inBundle:bundle compatibleWithTraitCollection:nil]);
    XCTAssertNotNil([bundle URLForResource:@"PrivacyInfo" withExtension:@"xcprivacy"]);
}
- (void)testPlayerCertificateBelongsToHost {
    XCTAssertNil([DZDramaSDKManager.resourceBundle URLForResource:@"AliVideoCert-hmjc" withExtension:@"crt"]);
    NSString *licenseKey = [NSBundle.mainBundle objectForInfoDictionaryKey:@"AlivcLicenseKey"];
    if (licenseKey.length == 0) {
        XCTSkip(@"公开示例不包含播放器授权；配置宿主证书后再验证播放器授权文件位置");
        return;
    }
    XCTAssertNotNil([NSBundle.mainBundle URLForResource:@"AliVideoCert-hmjc" withExtension:@"crt"]);
    XCTAssertEqualObjects([NSBundle.mainBundle objectForInfoDictionaryKey:@"AlivcLicenseFile"], @"AliVideoCert-hmjc.crt");
}
- (void)testServiceConfigurationBelongsToSDKAndHasNoHostSetters {
    NSURL *url = [DZDramaSDKManager.resourceBundle URLForResource:@"DZOperaConfig" withExtension:@"plist"];
    XCTAssertNotNil(url);
    XCTAssertNil([NSBundle.mainBundle URLForResource:@"DZOperaConfig" withExtension:@"plist"]);
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfURL:url];
    NSString *environment = settings[@"APIEnvironment"];
    XCTAssertNotNil(settings[@"BaseURLs"][environment]);
    DZDramaConfiguration *configuration = [DZDramaConfiguration new];
    for (NSString *selector in @[@"baseURL", @"setBaseURL:", @"productCode", @"setProductCode:", @"apiVersion", @"setApiVersion:"]) {
        XCTAssertFalse([configuration respondsToSelector:NSSelectorFromString(selector)]);
    }
}
- (void)testObjectiveCInitializationReportsFailureWithoutNetwork {
    XCTestExpectation *callback = [self expectationWithDescription:@"Objective-C initialization callback"];
    DZDramaConfiguration *configuration = [DZDramaConfiguration new];
    configuration.appKey = @"";
    [DZDramaSDKManager.shared initializeWithConfiguration:configuration completion:^(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, -100005);
        XCTAssertTrue(NSThread.isMainThread);
        [callback fulfill];
    }];
    [self waitForExpectations:@[callback] timeout:5];
}
- (void)testObjectiveCEventCallbackAndStaticCategoriesAreLinked {
    UIViewController *page = [UIViewController new];
    page.DZ_pageTitle = @"OC binary integration";
    XCTAssertEqualObjects(page.DZ_pageTitle, @"OC binary integration");
    __block BOOL called = NO;
    DZDramaSDKManager.shared.eventHandler = ^(NSString *name, NSDictionary *properties) {
        called = YES;
        XCTAssertEqualObjects(name, @"$AppViewScreen");
        XCTAssertEqualObjects(properties[@"pageName"], @"binary");
    };
    [DZExposureEventBridge DZ_trackPageWithName:@"binary" pageTitle:@"OC" positionName:nil pageAddress:nil extMap:nil];
    XCTAssertTrue(called);
    DZDramaSDKManager.shared.eventHandler = nil;
}
@end
