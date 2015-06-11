//
//  UIImageView+RJAdditions.h
//  Community
//

#import <FastImageCache/FICEntity.h>
#import <UIKit/UIKit.h>


@interface UIImageView (RJAdditions)

- (void)setImageEntity:(NSObject<FICEntity> *)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder;

@end
