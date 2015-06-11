//
//  RJCommentCell.m
//  Community
//


#import "RJCommentCell.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectMessage.h"
#import "RJManagedObjectUser.h"
#import "RJStyleManager.h"
#import <ActionLabel/ActionLabel.h>

static CGFloat const kImageSideLength = 12.0f;
static CGFloat const kImageLeftRightPadding = 8.0f;
static CGFloat const kImageTopBottomPadding = 4.0f;

static CGFloat const kActionLabelLeftPadding = 10.0f;
static CGFloat const kActionLabelRightPadding = 10.0f;


@implementation RJCommentCell

#pragma mark - Private Instance Methods

- (CGRect)frameForActionLabel {
    CGFloat actionLabelOriginX = 0.0f;
    if (self.offsetForImageView) {
        actionLabelOriginX += (2*kImageLeftRightPadding);
        actionLabelOriginX += kImageSideLength;
    } else {
        actionLabelOriginX += kActionLabelLeftPadding;
    }
    
    CGFloat actionLabelWidth = CGRectGetWidth(self.contentView.bounds);
    actionLabelWidth -= actionLabelOriginX;
    actionLabelWidth -= kActionLabelRightPadding;
    
    return CGRectMake(actionLabelOriginX, 0.0f, actionLabelWidth, CGRectGetHeight(self.contentView.bounds));
}

#pragma mark - Public Instance Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.offsetForImageView) {
        self.imageView.frame = CGRectMake(kImageLeftRightPadding, kImageTopBottomPadding, kImageSideLength, kImageSideLength);
    } else {
        self.imageView.frame = CGRectZero;
    }
    self.commentLabel.frame = [self frameForActionLabel];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _commentLabel = [[ActionLabel alloc] initWithFrame:self.bounds];
        _commentLabel.numberOfLines = 0;
        [self.contentView addSubview:_commentLabel];
    }
    return self;
}

- (void)updateWithMessage:(RJManagedObjectMessage *)message blockForSender:(void (^)(RJManagedObjectUser *))block {
    [self.commentLabel clearRegisteredBlocks];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] init];
    
    RJManagedObjectUser *sender = message.sender;
    NSString *messageSenderName = sender.name;
    
    if (messageSenderName) {
        NSAttributedString *attrName = [[NSAttributedString alloc] initWithString:messageSenderName
                                                                       attributes:styleManager.boldLinkTextAttributes];
        [mutableAttr appendAttributedString:attrName];
    }
    
    NSString *commentString = [NSString stringWithFormat:@" %@", message.text];
    if (commentString) {
        NSAttributedString *attrCommentString = [[NSAttributedString alloc] initWithString:commentString
                                                                                attributes:styleManager.plainTextAttributes];
        [mutableAttr appendAttributedString:attrCommentString];
    }
    
    self.commentLabel.attributedText = mutableAttr;
    
    [self.commentLabel registerBlock:^{
        if (block) {
            block(sender);
        }
    }
                            forRange:NSMakeRange(0, messageSenderName.length)
                 highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
    
}

- (void)updateWithComment:(RJManagedObjectComment *)comment blockForCreator:(void (^)(RJManagedObjectUser *creator))block {
    [self.commentLabel clearRegisteredBlocks];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] init];
    
    RJManagedObjectUser *creator = comment.creator;
    NSString *commentCreatorName = creator.name;
    
    if (commentCreatorName) {
        NSAttributedString *attrName = [[NSAttributedString alloc] initWithString:commentCreatorName
                                                                       attributes:styleManager.boldLinkTextAttributes];
        [mutableAttr appendAttributedString:attrName];
    }

    NSString *commentString = [NSString stringWithFormat:@" %@", comment.text];
    if (commentString) {
        NSAttributedString *attrCommentString = [[NSAttributedString alloc] initWithString:commentString
                                                                                attributes:styleManager.plainTextAttributes];
        [mutableAttr appendAttributedString:attrCommentString];
    }
    
    self.commentLabel.attributedText = mutableAttr;
    
    [self.commentLabel registerBlock:^{
        if (block) {
            block(creator);
        }
    }
                            forRange:NSMakeRange(0, commentCreatorName.length)
                 highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
}

- (void)updateWithNumberOfComments:(NSUInteger)number blockForSelection:(void (^)(void))block {
    [self.commentLabel clearRegisteredBlocks];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    NSString *text = [NSString stringWithFormat:@"view all %lu comments", (long)number];
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text
                                                                   attributes:styleManager.grayLinkTextAttributes];
    self.commentLabel.attributedText = attrText;
    [self.commentLabel registerBlock:^{
        if (block) {
            block();
        }
    }
                            forRange:NSMakeRange(0, text.length)
                 highlightAttributes:styleManager.highlightedGrayLinkTextAttributes];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [self.commentLabel sizeThatFits:CGSizeMake(CGRectGetWidth([self frameForActionLabel]), CGFLOAT_MAX)];
    if (self.offsetForImageView) {
        CGFloat imageViewHeight = (kImageSideLength + 2*kImageTopBottomPadding);
        sizeThatFits.height = MAX(sizeThatFits.height, imageViewHeight);
    }
    return sizeThatFits;
}

@end
