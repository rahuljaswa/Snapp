//
//  RJUserPickerViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 4/23/15.
//
//

#import <UIKit/UIKit.h>


@class RJUserPickerViewController;

@protocol RJUserPickerViewControllerDelegate <NSObject>

- (void)userPickerViewControllerDidCancel:(RJUserPickerViewController *)userPickerViewController;
- (void)userPickerViewControllerDidFinish:(RJUserPickerViewController *)userPickerViewController;

@end


@class RJManagedObjectUser;

@interface RJUserPickerViewController : UITableViewController

@property (nonatomic, weak) id<RJUserPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) RJManagedObjectUser *selectedUser;

- (instancetype)initWithInitiallySelectedUser:(RJManagedObjectUser *)user;

@end
