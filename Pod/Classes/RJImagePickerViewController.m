//
//  RJImagePickerViewController.m
//  Community
//

#import "RJGridCell.h"
#import "RJImagePickerViewController.h"
#import "RJPostImageCacheEntity.h"
#import "RJStyleManager.h"
@import AssetsLibrary.ALAsset;
@import AssetsLibrary.ALAssetsGroup;
@import AssetsLibrary.ALAssetsLibrary;
@import AssetsLibrary.ALAssetRepresentation;

static NSString *const kRJGridCellReuseID = @"RJGridCellReuseID";


@interface RJImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong, readonly) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

@property (nonatomic, strong) NSMutableArray *mutableSelectedImages;

@end


@implementation RJImagePickerViewController

#pragma mark - Public Properties

- (NSArray *)selectedImages {
    return self.mutableSelectedImages;
}

#pragma mark - Private Protocols - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *newImage = info[UIImagePickerControllerOriginalImage];
    
    ALAssetsLibraryWriteImageCompletionBlock writeBlock;
    writeBlock = ^(NSURL *assetURL, NSError *error) {
        [self.assetsLibrary assetForURL:assetURL
                            resultBlock:^(ALAsset *asset) {
                                NSMutableArray *mutableSelectedIndexes = [[NSMutableArray alloc] init];
                                for (NSNumber *number in self.selectedIndexes) {
                                    [mutableSelectedIndexes addObject:@([number integerValue] + 1)];
                                }
                                self.selectedIndexes = mutableSelectedIndexes;
                                
                                [self.images insertObject:asset atIndex:0];
                                [self addSelectedIndex:0];
                                
                                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                                [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                                [self.collectionView selectItemAtIndexPath:newIndexPath
                                                                  animated:NO
                                                            scrollPosition:UICollectionViewScrollPositionNone];
                                
                                [self updateTitle];
                                if ([self.pickerDelegate respondsToSelector:@selector(imagePickerViewControllerSelectedImagesDidChange:)]) {
                                    [self.pickerDelegate imagePickerViewControllerSelectedImagesDidChange:self];
                                }
                                [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                            }
                           failureBlock:^(NSError *error) {
                               [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                           }];
    };
    
    [self.assetsLibrary writeImageToSavedPhotosAlbum:newImage.CGImage
                                            metadata:nil
                                     completionBlock:writeBlock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private Protocols - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemsPerLine = 3.0f;
    CGFloat usableWidth = (CGRectGetWidth(collectionView.bounds) - ((itemsPerLine + 1.0f) * 1.0f));
    CGFloat width = ceil(usableWidth/3.0f);
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    NSUInteger adjustedIndex = (indexPath.item - 1);
    [self removeSelectedIndex:adjustedIndex];
    cell.selected = [self.selectedIndexes containsObject:@(adjustedIndex)];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self updateTitle];
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerViewControllerSelectedImagesDidChange:)]) {
        [self.pickerDelegate imagePickerViewControllerSelectedImagesDidChange:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if ((indexPath.section == 0) && (indexPath.item == 0)) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        NSUInteger adjustedIndex = (indexPath.item - 1);
        [self addSelectedIndex:adjustedIndex];
        cell.selected = [self.selectedIndexes containsObject:@(adjustedIndex)];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self updateTitle];
        if ([self.pickerDelegate respondsToSelector:@selector(imagePickerViewControllerSelectedImagesDidChange:)]) {
            [self.pickerDelegate imagePickerViewControllerSelectedImagesDidChange:self];
        }
    }
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellReuseID forIndexPath:indexPath];
    cell.backgroundView.backgroundColor = [[RJStyleManager sharedInstance] loadingImageBackgroundColor];
    
    if (indexPath.item == 0) {
        cell.image.contentMode = UIViewContentModeCenter;
        cell.image.backgroundColor = [UIColor whiteColor];
        cell.selectedColor = [UIColor lightGrayColor];
        
        [cell updateWithImage:[UIImage imageNamed:@"cameraIcon"] formatName:nil displaysLoadingIndicator:NO];
    } else {
        cell.image.contentMode = UIViewContentModeScaleAspectFit;
        cell.image.backgroundColor = [[RJStyleManager sharedInstance] loadingImageBackgroundColor];
        cell.selectedColor = [[RJStyleManager sharedInstance] themeColor];
        
        NSUInteger adjustedIndex = (indexPath.item - 1);
        cell.selected = [self.selectedIndexes containsObject:@(adjustedIndex)];
        if (cell.selected) {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        
        id image = [self.images objectAtIndex:adjustedIndex];
        [cell updateWithImage:image formatName:kRJPostImageFormatCardSquare16BitBGR displaysLoadingIndicator:NO];
    }
    
    return cell;
}

#pragma mark - Private Instance Methods

- (void)addSelectedIndex:(NSUInteger)index {
    [self.selectedIndexes addObject:@(index)];
    id image = [self.images objectAtIndex:index];
    if ([image isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)image;
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGImageRef imageRef = assetRep.fullScreenImage;
        image = [UIImage imageWithCGImage:imageRef];
    }
    [self.mutableSelectedImages addObject:image];
}

- (void)removeSelectedIndex:(NSUInteger)index {
    NSUInteger indexInSelectedImages = [self.selectedIndexes indexOfObject:@(index)];
    [self.selectedIndexes removeObjectAtIndex:indexInSelectedImages];
    [self.mutableSelectedImages removeObjectAtIndex:indexInSelectedImages];
}

- (void)updateTitle {
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Images", nil), @([self.selectedIndexes count])];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _selectedIndexes = [[NSMutableArray alloc] init];
        _mutableSelectedImages = [[NSMutableArray alloc] init];
        _images = [[NSMutableArray alloc] init];
        
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                              __block NSUInteger startingIndex = [_images count];
                                              [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                  if (result) {
                                                      [_images insertObject:result atIndex:startingIndex];
                                                  }
                                              }];
                                              [self.collectionView reloadData];
                                          }
                                        failureBlock:^(NSError *error) {
                                            NSLog(@"Failed to loadData for image picker\n%@",
                                                  [error localizedDescription]);
                                        }];
        });
    }
    return self;
}

- (instancetype)initWithInitiallySelectedImages:(NSArray *)images {
    self = [self init];
    if (self) {
        for (NSUInteger i = 0; i < [images count]; i++) {
            id image = [images objectAtIndex:i];
            [_images addObject:image];
            [self addSelectedIndex:i];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellReuseID];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self updateTitle];
}

@end
