//
//  RJLabelCell.m
//  Community
//

#import "RJLabelCell.h"
#import <SZTextView/SZTextView.h>


@interface RJLabelCell ()

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJLabelCell

- (void)setStyle:(RJLabelCellStyle)style {
    _style = style;
    switch (style) {
        case kRJLabelCellStyleTextField:
            self.textField.hidden = NO;
            self.textLabel.hidden = YES;
            self.textView.hidden = YES;
            break;
        case kRJLabelCellStyleTextLabel:
            self.textField.hidden = YES;
            self.textLabel.hidden = NO;
            self.textView.hidden = YES;
            break;
        case kRJLabelCellStyleTextView:
            self.textField.hidden = YES;
            self.textLabel.hidden = YES;
            self.textView.hidden = NO;
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        _textField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.rightViewMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:_textField];
        
        _textView = [[SZTextView alloc] initWithFrame:self.contentView.bounds];
        _textView.textContainerInset = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
        _textView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.contentView addSubview:_textView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textLabel];
        
        _accessoryView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _accessoryView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_accessoryView];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.style = kRJLabelCellStyleTextLabel;
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel, _accessoryView, _topBorder, _bottomBorder);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textLabel][_accessoryView(==40)]|"
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
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_accessoryView]|"
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
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
