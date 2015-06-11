//
//  RJProfileHeaderView.m
//  Community
//

#import "RJProfileHeaderView.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"


@interface RJProfileHeaderView ()

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        _setupStaticConstraints = NO;
        
        _headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerButton.contentEdgeInsets = UIEdgeInsetsMake(7.0f, 0.0f, 7.0f, 0.0f);
        _headerButton.clipsToBounds = YES;
        _headerButton.layer.cornerRadius = 3.0f;
        [self addSubview:_headerButton];
        
        _postsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _postsButton.titleLabel.numberOfLines = 2;
        [self addSubview:_postsButton];
        
        _likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likesButton.titleLabel.numberOfLines = 2;
        [self addSubview:_likesButton];
        
        _commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentsButton.titleLabel.numberOfLines = 2;
        [self addSubview:_commentsButton];
        
        _followersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followersButton.titleLabel.numberOfLines = 2;
        [self addSubview:_followersButton];
        
        _followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followingButton.titleLabel.numberOfLines = 2;
        [self addSubview:_followingButton];
        
        _categoriesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _categoriesButton.titleLabel.numberOfLines = 2;
        [self addSubview:_categoriesButton];
        
        _bio = [[UILabel alloc] initWithFrame:CGRectZero];
        _bio.textColor = styleManager.plainTextColor;
        _bio.font = styleManager.plainTextFont;
        [self addSubview:_bio];
        
        _name = [[UILabel alloc] initWithFrame:CGRectZero];
        _name.textColor = styleManager.plainTextColor;
        _name.font = styleManager.boldTextFont;
        [self addSubview:_name];
        
        _image = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_image];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.setupStaticConstraints) {
        UIView *headerButton = self.headerButton;
        headerButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *postsButton = self.postsButton;
        postsButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *likesButton = self.likesButton;
        likesButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *commentsButton = self.commentsButton;
        commentsButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *categoriesButton = self.categoriesButton;
        categoriesButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *followersButton = self.followersButton;
        followersButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *followingButton = self.followingButton;
        followingButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *bio = self.bio;
        bio.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *name = self.name;
        name.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *image = self.image;
        image.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(headerButton, postsButton, likesButton, commentsButton, categoriesButton, followingButton, followersButton, bio, name, image);
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[image]-10-[name]-10-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[likesButton][categoriesButton(==likesButton)]-5-[headerButton]"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[image(<=80)]-15-[headerButton]-10-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        // buttons vertical
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:postsButton
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:likesButton
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:likesButton
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:commentsButton
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:categoriesButton
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:postsButton
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:followersButton
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:categoriesButton
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:followingButton
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:categoriesButton
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0.0f]];
        // buttons horizontal
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:postsButton
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:headerButton
                                      attribute:NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:commentsButton
                                      attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:headerButton
                                      attribute:NSLayoutAttributeRight
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:categoriesButton
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:headerButton
                                      attribute:NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:followersButton
                                      attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:headerButton
                                      attribute:NSLayoutAttributeRight
                                     multiplier:1.0f
                                       constant:0.0f]];
        
        NSString *buttonsRow1HFormat = @"H:[postsButton][likesButton(==postsButton)][commentsButton(==postsButton)]";
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:buttonsRow1HFormat
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        NSString *buttonsRow2HFormat = @"H:[categoriesButton][followingButton(==postsButton)][followersButton(==categoriesButton)]";
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:buttonsRow2HFormat
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:image
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:image
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:image
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:name
                                      attribute:NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0.0f]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
