//
//  RJPostCell.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJManagedObjectPostCategory;
@class RJRemoteObjectLike;
@class RJRemoteObjectPost;
@class RJPostCell;
@class RJRemoteObjectUser;

@protocol RJPostCellDelegate <NSObject>

- (void)postCell:(RJPostCell *)postCell didPressLocation:(CLLocation *)location locationDescription:(NSString *)locationDescription;
- (void)postCell:(RJPostCell *)postCell didPressCategory:(RJManagedObjectPostCategory *)category;
- (void)postCell:(RJPostCell *)postCell didPressUser:(RJManagedObjectUser *)user;
- (void)postCellDidPressCommentButton:(RJPostCell *)postCell;
- (void)postCellDidPressLikeButton:(RJPostCell *)postCell;
- (void)postCellDidPressMessageButton:(RJPostCell *)postCell;
- (void)postCellDidPressMoreButton:(RJPostCell *)postCell;

@end


@class ActionLabel, RJManagedObjectPost;

@interface RJPostCell : UICollectionViewCell

@property (nonatomic, weak) id<RJPostCellDelegate> delegate;

@property (strong, nonatomic, readonly) RJManagedObjectLike *currentUserLike;
@property (strong, nonatomic) RJManagedObjectPost *post;

@property (strong, nonatomic, readonly) UIButton *commentButton;
@property (strong, nonatomic, readonly) UIButton *likeButton;
@property (strong, nonatomic, readonly) UIButton *messageButton;
@property (strong, nonatomic, readonly) UIButton *moreButton;

@property (strong, nonatomic, readonly) UITableView *detailsTable;
@property (strong, nonatomic, readonly) UICollectionView *imageCV;

- (void)preloadPostImages:(NSArray *)images;

@end
