//
//  RJNotificationCell.m
//  Community
//

#import "RJNotificationCell.h"
#import <ActionLabel/ActionLabel.h>

static const CGFloat kRJNotificationCellPaddingTop     = 20.0f;
static const CGFloat kRJNotificationCellPaddingBottom  = 20.0f;
static const CGFloat kRJNotificationCellPaddingRight   = 5.0f;


@implementation RJNotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _actionLabel = [[ActionLabel alloc] initWithFrame:self.bounds];
        _actionLabel.numberOfLines = 0;
        [self.contentView addSubview:_actionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat actionLabelMaxWidth = CGRectGetWidth(self.contentView.bounds);
    actionLabelMaxWidth -= self.separatorInset.left;
    actionLabelMaxWidth -= kRJNotificationCellPaddingRight;
    
    CGFloat actionLabelX = self.separatorInset.left;
    CGSize actionLabelSize = CGSizeMake(actionLabelMaxWidth, CGFLOAT_MAX);
    CGFloat actionLabelHeight = [self.actionLabel sizeThatFits:actionLabelSize].height;
    CGFloat actionLabelY = CGRectGetHeight(self.contentView.bounds)/2.0f - actionLabelHeight/2.0f;
    self.actionLabel.frame = CGRectMake(actionLabelX, actionLabelY, actionLabelMaxWidth, actionLabelHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = [super sizeThatFits:size];
    
    CGFloat actionLabelMaxWidth = size.width;
    actionLabelMaxWidth -= self.separatorInset.left;
    actionLabelMaxWidth -= kRJNotificationCellPaddingRight;
    
    CGSize actionLabelSize = CGSizeMake(actionLabelMaxWidth, CGFLOAT_MAX);
    CGFloat actionLabelHeight = [self.actionLabel sizeThatFits:actionLabelSize].height;
    CGFloat imageViewHeight = CGRectGetHeight(self.imageView.bounds);
    
    CGFloat newHeight = MAX(actionLabelHeight, imageViewHeight);
    newHeight += kRJNotificationCellPaddingTop;
    newHeight += kRJNotificationCellPaddingBottom;
    
    newSize.height = newHeight;

    return newSize;
}

@end
