//
//  UIButton+RJAdditions.m
//  Community
//

#import "UIButton+RJAdditions.h"


@implementation UIButton (RJAdditions)

- (void)centerWithSpacing:(CGFloat)spacing padding:(CGFloat)padding {
    CGFloat insetAmount = spacing / 2.0;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
    self.contentEdgeInsets = UIEdgeInsetsMake(padding, insetAmount + padding, padding, insetAmount + padding);
}

@end
