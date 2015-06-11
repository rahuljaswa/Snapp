//
//  RJSwitchCell.h
//  Pods
//
//  Created by Rahul Jaswa on 3/2/15.
//
//

#import <UIKit/UIKit.h>


@interface RJSwitchCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UISwitch *switchControl;
@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
