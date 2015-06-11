//
//  RJFeedViewController.h
//  Community
//

#import "RJViewControllerDataSourceProtocol.h"
#import <UIKit/UIKit.h>


@class CLLocation;
@class RJManagedObjectPost;

@interface RJFeedViewController : UICollectionViewController <RJViewControllerDataSourceProtocol>

@property (nonatomic, strong) NSArray *posts;

- (instancetype)initWithPost:(RJManagedObjectPost *)post;

@end
