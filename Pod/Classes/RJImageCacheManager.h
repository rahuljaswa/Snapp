//
//  RJImageCacheManager.h
//  Community
//

#import <FastImageCache/FICImageCache.h>
@import Foundation;


@interface RJImageCacheManager : NSObject <FICImageCacheDelegate>

+ (NSArray *)formats;

@end
