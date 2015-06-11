//
//  RJPostHeaderView.h
//  Community
//

#import <UIKit/UIKit.h>


@class ActionLabel;

@interface RJPostHeaderView : UICollectionReusableView

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) ActionLabel *userName;
@property (nonatomic, strong, readonly) UILabel *timestamp;
@property (nonatomic, strong, readonly) UILabel *name;

@end
