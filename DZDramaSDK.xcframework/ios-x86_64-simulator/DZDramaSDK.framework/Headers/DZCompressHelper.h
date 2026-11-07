//
//  DZCompressHelper.h
//  HMPlayModules
//
//  Created by Dzkk4 on 2024/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DZCompressHelper : NSObject

+(NSData *)lz4Compress:(NSData *)src;

+(NSData *)lz4DeCompress:(NSData *)src;
@end

NS_ASSUME_NONNULL_END
