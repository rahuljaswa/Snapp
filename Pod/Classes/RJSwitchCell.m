//
//  RJSwitchCell.m
//  Pods
//
//  Created by Rahul Jaswa on 3/2/15.
//
//

#import "RJSwitchCell.h"


@interface RJSwitchCell ()

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJSwitchCell

@synthesize switchControl = _switchControl;
@synthesize textLabel = _textLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_switchControl];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textLabel];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        _switchControl.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel, _switchControl, _topBorder, _bottomBorder);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textLabel][_switchControl(==60)]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(==0.5)]"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomBorder(==0.5)]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_switchControl
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0.0f]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}



@end
