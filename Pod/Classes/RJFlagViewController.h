//
//  RJFlagViewController.h
//  Community
//

#import "RJManagedObjectFlag.h"
#import <UIKit/UIKit.h>


@class RJFlagViewController;

@protocol RJFlagViewControllerDelegate <NSObject>

- (void)flagViewControllerDidPressCancelButton:(RJFlagViewController *)flagViewController;
- (void)flagViewController:(RJFlagViewController *)flagViewController didSelectReason:(RJManagedObjectFlagReason)reason;

@end


@class RJManagedObjectPost;

@interface RJFlagViewController : UITableViewController

@property (nonatomic, weak) id<RJFlagViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) RJManagedObjectPost *post;

- (instancetype)initWithPost:(RJManagedObjectPost *)post;

@end
