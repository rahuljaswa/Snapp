//
//  UINavigationItem+RJAdditions.m
//  Community
//

#import "UINavigationItem+RJAdditions.h"

@implementation UINavigationItem (RJAdditions)

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    item.tintColor = [UIColor whiteColor];
    return item;
}

@end
