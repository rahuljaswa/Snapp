//
//  RJProfileHeaderView.h
//  Community
//

#import <UIKit/UIKit.h>


@interface RJProfileHeaderView : UICollectionReusableView

@property (nonatomic, strong, readonly) UILabel *bio;
@property (nonatomic, strong, readonly) UIImageView *image;
@property (nonatomic, strong, readonly) UILabel *name;

@property (nonatomic, strong, readonly) UIButton *headerButton;

@property (nonatomic, strong, readonly) UIButton *followersButton;
@property (nonatomic, strong, readonly) UIButton *followingButton;
@property (nonatomic, strong, readonly) UIButton *categoriesButton;

@property (nonatomic, strong, readonly) UIButton *likesButton;
@property (nonatomic, strong, readonly) UIButton *postsButton;
@property (nonatomic, strong, readonly) UIButton *commentsButton;

@end
