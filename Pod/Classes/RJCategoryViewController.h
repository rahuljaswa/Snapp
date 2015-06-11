//
//  RJCategoryViewController.h
//  Community
//

#import "RJGalleryViewController.h"
#import "RJViewControllerDataSourceProtocol.h"


@class RJManagedObjectPostCategory;

@interface RJCategoryViewController : RJGalleryViewController <RJViewControllerDataSourceProtocol>

- (instancetype)initWithCategory:(RJManagedObjectPostCategory *)category;

@end
