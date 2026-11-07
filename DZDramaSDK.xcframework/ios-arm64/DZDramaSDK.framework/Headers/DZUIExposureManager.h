//
//  DZUIExposureManager.h
//  DZUIExposureManager


#import <Foundation/Foundation.h>

@class UIView, UIViewController;

@interface DZUIExposureManager : NSObject
@property (nonatomic, strong, class, readonly) DZUIExposureManager *DZ_sharedManager;

//加入监听队列--但是未必就开始监听，只有对应控制器/uiwindow也处于展示状态才会监听
- (void)DZ_listenExposureView:(UIView *)view;
- (void)DZ_listenExposureViewController:(UIViewController *)VC;
- (void)DZ_dismissExposureViewController:(UIViewController *)VC;
@end
