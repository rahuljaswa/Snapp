//
//  RJUserImageCacheEntity.h
//  Community
//

#import <FastImageCache/FICEntity.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyUser;

FOUNDATION_EXPORT NSString *const kRJUserImageFormatCard16BitBGR40x40;
FOUNDATION_EXPORT CGSize const kRJUserImageSize40x40;

FOUNDATION_EXPORT NSString *const kRJUserImageFormatCard16BitBGR80x80;
FOUNDATION_EXPORT CGSize const kRJUserImageSize80x80;


@interface RJUserImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithUserImageURL:(NSURL *)imageURL objectID:(NSString *)objectID;

@end
