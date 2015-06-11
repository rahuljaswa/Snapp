//
//  RJTagPickerViewController.h
//  Community
//

#import "RJViewControllerDataSourceProtocol.h"
#import <UIKit/UIKit.h>


@class RJTagPickerViewController;

@protocol RJTagPickerViewControllerDelegate <NSObject>

- (void)tagPickerViewControllerSelectedTagsDidChange:(RJTagPickerViewController *)tagPickerViewController;

@end


@interface RJTagPickerViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray *selectedCreatedTags;
@property (nonatomic, strong, readonly) NSArray *selectedExistingTags;
@property (nonatomic, weak) id<RJTagPickerViewControllerDelegate> pickerDelegate;

- (instancetype)initWithInitiallySelectedExistingTags:(NSArray *)initiallySelectedExistingTags initiallySelectedCreatedTags:(NSArray *)initiallySelectedCreatedTags;

@end
