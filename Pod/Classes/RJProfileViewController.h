//
//  RJProfileViewController.h
//  Community
//

#import "RJGalleryViewController.h"
#import "RJViewControllerDataSourceProtocol.h"
#import <UIKit/UIKit.h>


@class RJManagedObjectUser;

@interface RJProfileViewController : RJGalleryViewController <RJViewControllerDataSourceProtocol>

@property (nonatomic, assign) BOOL showsSettingsButton;

- (instancetype)initWithUser:(RJManagedObjectUser *)user;

@end
