//
//  NSObject+DZExtend.h
//  DZUIExposureManager


#import <Foundation/Foundation.h>
@class UIViewController;

@interface NSObject (DZExtend)
- (UIViewController *)DZ_topViewController;
- (UIViewController *)DZ_topViewController:(UIViewController *)rootViewController;
@end
