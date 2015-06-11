//
//  RJRelationsViewController.h
//  Community
//

#import "RJViewControllerDataSourceProtocol.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RJRelationsViewControllerUserRelationsType) {
    kRJRelationsViewControllerUserRelationsTypeBlockedUsers,
    kRJRelationsViewControllerUserRelationsTypeFollowers,
    kRJRelationsViewControllerUserRelationsTypeFollowingUsers,
    kRJRelationsViewControllerUserRelationsTypeFollowingCategories
};

typedef NS_ENUM(NSUInteger, RJRelationsViewControllerCategoryRelationsType) {
    kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers
};


@class RJManagedObjectPostCategory;
@class RJManagedObjectUser;

@interface RJRelationsViewController : UITableViewController <RJViewControllerDataSourceProtocol>

- (instancetype)initWithCategoryRelationsType:(RJRelationsViewControllerCategoryRelationsType)categoryRelationsType category:(RJManagedObjectPostCategory *)category;
- (instancetype)initWithUserRelationsType:(RJRelationsViewControllerUserRelationsType)userRelationsType user:(RJManagedObjectUser *)user;

@end
