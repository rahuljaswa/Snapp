//
//  RJLabelCell.h
//  Community
//

#import <UIKit/UIKit.h>
#import <SZTextView/SZTextView.h>

typedef NS_ENUM(NSUInteger, RJLabelCellStyle) {
    kRJLabelCellStyleTextLabel,
    kRJLabelCellStyleTextField,
    kRJLabelCellStyleTextView
};


@interface RJLabelCell : UICollectionViewCell

@property (nonatomic, assign) RJLabelCellStyle style;

@property (nonatomic, strong, readonly) UIImageView *accessoryView;
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) SZTextView *textView;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
