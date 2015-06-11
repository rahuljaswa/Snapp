//
//  RJCategoryHeaderView.m
//  Community
//

#import "RJCategoryHeaderView.h"
#import "RJStyleManager.h"


@interface RJCategoryHeaderView ()

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJCategoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _setupStaticConstraints = NO;
        
        _headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerButton.contentEdgeInsets = UIEdgeInsetsMake(7.0f, 0.0f, 7.0f, 0.0f);
        _headerButton.clipsToBounds = YES;
        _headerButton.layer.cornerRadius = 3.0f;
        [self addSubview:_headerButton];
        
        _postsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _postsButton.titleLabel.numberOfLines = 2;
        [self addSubview:_postsButton];
        
        _followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followingButton.titleLabel.numberOfLines = 2;
        [self addSubview:_followingButton];
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
        
        UIView *followingButton = self.followingButton;
        followingButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(headerButton, postsButton, followingButton);
        
        NSString *buttonsHFormat = @"H:|[postsButton(==80)]-15-[headerButton]-15-[followingButton(==postsButton)]|";
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:buttonsHFormat
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[postsButton]-10-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[followingButton]-10-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[headerButton]-10-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
