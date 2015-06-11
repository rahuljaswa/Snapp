//
//  RJCommentsViewController.h
//  Community
//

#import <ChatViewControllers/RJChatTableViewController.h>


@class RJCommentsViewController;
@class RJManagedObjectUser;

@protocol RJCommentsViewControllerDelegate <NSObject>

- (void)commentsViewController:(RJCommentsViewController *)postCell didPressUser:(RJManagedObjectUser *)user;
- (void)commentsViewController:(RJCommentsViewController *)commentsViewController didPressSendButtonWithText:(NSString *)text;

@end


@class RJManagedObjectPost;

@interface RJCommentsViewController : RJChatTableViewController

@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, weak) id<RJCommentsViewControllerDelegate> commentsDelegate;
@property (nonatomic, strong, readonly) RJManagedObjectPost *post;

- (instancetype)initWithPost:(RJManagedObjectPost *)post;

@end
