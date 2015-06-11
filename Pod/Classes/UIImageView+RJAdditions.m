//
//  UIImageView+RJAdditions.m
//  Community
//

#import "UIImageView+RJAdditions.h"
#import <FastImageCache/FICImageCache.h>


@implementation UIImageView (RJAdditions)

- (void)setImageEntity:(NSObject<FICEntity> *)entity
            formatName:(NSString *)formatName
           placeholder:(UIImage *)placeholder
{
    FICImageCache *imageCache = [FICImageCache sharedImageCache];
    if (![imageCache imageExistsForEntity:entity withFormatName:formatName]) {
        self.image = placeholder;
    }
    
    __weak __typeof(self) weakSelf = self;
    [imageCache retrieveImageForEntity:entity
                        withFormatName:formatName
                       completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image)
     {
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         if (strongSelf) {
             strongSelf.image = image;
         }
     }];
}

@end
