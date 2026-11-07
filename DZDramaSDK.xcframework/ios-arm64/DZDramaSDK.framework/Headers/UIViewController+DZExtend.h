//
//  UIViewController+DZExtend.h
//  DZUIExposureManager


#import <UIKit/UIKit.h>

@interface UIViewController (DZExtend)
@property (nonatomic, assign, readonly) BOOL DZ_viewDidAppeared;
@property (nonatomic, assign, readonly) BOOL DZ_viewWillDisappeared;
@property (nonatomic, assign, setter=DZ_setIgnoreTrackViewScreen:) BOOL DZ_ignoreTrackViewScreen;
@property (nonatomic, copy, setter=DZ_setPageTitle:) NSString * _Nullable DZ_pageTitle;

- (NSDictionary <NSString *, id>* _Nullable)DZ_extraPageViewParams;
@end
