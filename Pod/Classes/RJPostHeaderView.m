//
//  RJPostHeaderView.m
//  Community
//

#import "RJPostHeaderView.h"
#import <ActionLabel/ActionLabel.h>


@implementation RJPostHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomBorder];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        _timestamp = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_timestamp];
        
        _name = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_name];
        
        _userName = [[ActionLabel alloc] initWithFrame:CGRectZero];
        _userName.numberOfLines = 0;
        [self addSubview:_userName];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    UIView *b = self.bottomBorder;
    b.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *i = self.imageView;
    i.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *t = self.timestamp;
    t.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *n = self.userName;
    n.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *ti = self.name;
    ti.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(b, i, t, ti, n);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[b]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[i]-10-[n]-5-[t(==30)]-5-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b(==0.5)]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[i]-5-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[n][ti(==n)]-7-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[t]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:i
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:i
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1.0f
                                   constant:0.0f]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:n
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:ti
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1.0f
                                   constant:0.0f]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:n
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:ti
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1.0f
                                   constant:0.0f]];
    
    [super updateConstraints];
}

@end
