//
//  RJPostImageCacheEntity.h
//  Community
//

#import <FastImageCache/FICEntity.h>
@import CoreGraphics;
@import Foundation;

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyPost;
FOUNDATION_EXPORT NSString *const kRJPostImageFormatCardSquare16BitBGR;
FOUNDATION_EXPORT NSString *const kRJPostImageFormatCard16BitBGR;
FOUNDATION_EXPORT CGSize const kRJPostImageSizeCard;


@interface RJPostImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithPostImageURL:(NSURL *)imageURL objectID:(NSString *)objectID;

@end
