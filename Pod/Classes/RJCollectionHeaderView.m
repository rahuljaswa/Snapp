//
//  RJCollectionHeaderView.m
//  Community
//

#import "RJCollectionHeaderView.h"
#import "RJStyleManager.h"


@implementation RJCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = [[RJStyleManager sharedInstance] plainTextFont];
        _label.textColor = [[RJStyleManager sharedInstance] plainTextColor];
        
        UIView *l = _label;
        l.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:l];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(l);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-<=10-[l]-<=10-|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-<=5-[l]-<=5-|" options:0 metrics:nil views:views]];
    }
    return self;
}

@end
