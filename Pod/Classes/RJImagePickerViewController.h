//
//  RJImagePickerViewController.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJImagePickerViewController;

@protocol RJImagePickerViewControllerDelegate <NSObject>

- (void)imagePickerViewControllerSelectedImagesDidChange:(RJImagePickerViewController *)imagePickerViewController;

@end


@interface RJImagePickerViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, weak) id<RJImagePickerViewControllerDelegate> pickerDelegate;

- (instancetype)initWithInitiallySelectedImages:(NSArray *)images;

@end
