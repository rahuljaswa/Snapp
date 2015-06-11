//
//  RJCommentCell.h
//  Community
//

#import <UIKit/UIKit.h>


@class ActionLabel;
@class RJManagedObjectComment;
@class RJManagedObjectMessage;
@class RJManagedObjectUser;

@interface RJCommentCell : UITableViewCell

@property (nonatomic, strong, readonly) ActionLabel *commentLabel;
@property (nonatomic, assign) BOOL offsetForImageView;

- (void)updateWithMessage:(RJManagedObjectMessage *)message blockForSender:(void (^)(RJManagedObjectUser *sender))block;
- (void)updateWithComment:(RJManagedObjectComment *)comment blockForCreator:(void (^)(RJManagedObjectUser *creator))block;
- (void)updateWithNumberOfComments:(NSUInteger)number blockForSelection:(void (^)(void))block;

@end
