//
//  NSObject+DZSwizzle.h
//  HMSingnalTest


#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DZSwizzle)
+ (BOOL)DZ_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)DZ_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;
@end

@interface NSProxy (DZSwizzle)

+ (BOOL)DZ_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)DZ_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;

@end
NS_ASSUME_NONNULL_END
