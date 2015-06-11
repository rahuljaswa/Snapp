//
//  RJUserLikesViewController.h
//  Community
//

#import "RJGalleryViewController.h"
#import "RJViewControllerDataSourceProtocol.h"


@class RJManagedObjectUser;

@interface RJUserLikesViewController : RJGalleryViewController <RJViewControllerDataSourceProtocol>

- (instancetype)initWithLiker:(RJManagedObjectUser *)liker;

@end
