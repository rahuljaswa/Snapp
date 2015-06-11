//
//  RJCreateViewController.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJCreateViewController;

@protocol RJCreateViewControllerDelegate <NSObject>

- (void)createViewControllerDidCancel:(RJCreateViewController *)createViewController;
- (void)createViewControllerDidFinish:(RJCreateViewController *)createViewController;

@end


@class CLLocation;
@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJCreateViewController : UICollectionViewController

@property (nonatomic, weak) id<RJCreateViewControllerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL forSale;

@property (nonatomic, strong, readonly) CLLocation *location;
@property (nonatomic, strong, readonly) NSString *locationDescription;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *textDescription;

@property (nonatomic, strong, readonly) NSArray *selectedCreatedTags;
@property (nonatomic, strong, readonly) NSArray *selectedImages;
@property (nonatomic, strong, readonly) NSArray *selectedExistingTags;
@property (nonatomic, strong, readonly) RJManagedObjectUser *creator;

@property (nonatomic, strong, readonly) RJManagedObjectPost *post;

- (instancetype)initWithPost:(RJManagedObjectPost *)post;

@end
