//
//  NSRunLoop+DZObserver.h
//  DZUIExposureManager


#import <Foundation/Foundation.h>

@interface NSRunLoop (DZObserver)

- (CFRunLoopObserverRef)DZ_addObserverWith:(CFOptionFlags)activities repeats:(BOOL)repeats mode:(CFRunLoopMode)mode observerBlock:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverForOnceWith:(CFOptionFlags)activities mode:(CFRunLoopMode)mode observerBlock:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverWith:(CFOptionFlags)activities mode:(CFRunLoopMode)mode observerBlock:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverWith:(CFOptionFlags)activities observerBlock:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverForCommonModesWith:(CFOptionFlags)activities observerBlock:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverWith:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;
- (CFRunLoopObserverRef)DZ_addObserverForCommonModesWith:(void (^) (CFRunLoopObserverRef observer, CFRunLoopActivity activity))observerBlock;

- (void)DZ_removeObserverWith:(CFRunLoopObserverRef)observer mode:(CFRunLoopMode)mode;
- (void)DZ_removeObserverForCommonModesWith:(CFRunLoopObserverRef)observer;
@end
