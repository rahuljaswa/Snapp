//
//  UIImage+RJAdditions.h
//  Community
//

#import <UIKit/UIKit.h>

@interface UIImage (RJAdditions)

+ (instancetype)imageWithColor:(UIColor *)color;

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (instancetype)tintableImageNamed:(NSString *)named;

@end
