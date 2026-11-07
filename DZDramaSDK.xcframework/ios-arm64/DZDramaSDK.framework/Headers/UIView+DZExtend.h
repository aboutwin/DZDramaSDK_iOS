//
//  UIView+DZExtend.h
//  DZUIExposureManager


#import <UIKit/UIKit.h>

@interface UIView (DZExtend)

@property (nonatomic, strong, setter=DZ_setViewController:) UIViewController *DZ_viewController;
@property (nonatomic, assign, readonly) BOOL DZ_displayedInScreen;
/// 刚曝光时的时间，距离1970年
@property (nonatomic, assign, setter=DZ_setFirstExposureTime:) NSTimeInterval DZ_firstExposureTime;

/// 是否显示在当前显示的控制器上
- (BOOL)DZ_displayedInViewController;

@end
