//
//  RJGridCell.h
//  Community
//

#import <UIKit/UIKit.h>


@interface RJGridCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *title;
@property (nonatomic, strong, readonly) UIImageView *image;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinner;

@property (nonatomic, assign, getter = shouldDisableDuringLoading) BOOL disableDuringLoading;
@property (nonatomic, assign, getter = shouldMask) BOOL mask;

@property (nonatomic, strong) UIColor *selectedColor;

- (void)updateWithImage:(id)image formatName:(NSString *)formatName displaysLoadingIndicator:(BOOL)displaysLoadingIndicator;

@end
