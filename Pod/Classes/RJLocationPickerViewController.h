//
//  RJLocationPickerViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 4/5/15.
//
//

#import <UIKit/UIKit.h>


@class RJLocationPickerViewController;

@protocol RJLocationPickerViewControllerDelegate <NSObject>

- (void)locationPickerViewControllerSelectedLocationDidChange:(RJLocationPickerViewController *)locationPickerViewController;

@end


@class CLLocation;

@interface RJLocationPickerViewController : UITableViewController

@property (nonatomic, assign) id<RJLocationPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedLocationString;
@property (nonatomic, strong) CLLocation *selectedLocation;

- (instancetype)initWithInitiallySelectedLocation:(CLLocation *)location;

@end
