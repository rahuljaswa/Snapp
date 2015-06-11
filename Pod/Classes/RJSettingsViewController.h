//
//  RJSettingsViewController.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJSettingsViewController;

@protocol RJSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidLogout:(RJSettingsViewController *)settingsViewController;

@end


@interface RJSettingsViewController : UITableViewController

@property (nonatomic, weak) id<RJSettingsViewControllerDelegate> delegate;

@end
