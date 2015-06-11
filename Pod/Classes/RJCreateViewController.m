//
//  RJCreateViewController.m
//  Community
//

#import "RJRemoteObjectCategory.h"
#import "RJCollectionCell.h"
#import "RJCreateViewController.h"
#import "RJGridCell.h"
#import "RJImagePickerViewController.h"
#import "RJLabelCell.h"
#import "RJLocationPickerViewController.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJPostImageCacheEntity.h"
#import "RJRemoteObjectUser.h"
#import "RJStyleManager.h"
#import "RJSwitchCell.h"
#import "RJTagPickerViewController.h"
#import "RJTemplateManager.h"
#import "RJUserPickerViewController.h"
#import "UIImage+RJAdditions.h"
#import <SZTextView/SZTextView.h>

static NSString *const kRJCollectionCellID = @"RJCollectionCellID";
static NSString *const kRJGridCellID = @"RJGridCellID";
static NSString *const kRJLabelCellID = @"RJLabelCellID";
static NSString *const kRJSwitchCellID = @"RJSwitchCellID";

typedef NS_ENUM(NSUInteger, CreateSection) {
    kDetailsCreateSection,
    kTagsCreateSection,
    kImagesCreateSection,
    kNumCreateSections
};


@interface RJCreateViewController () <RJImagePickerViewControllerDelegate, RJLocationPickerViewControllerDelegate, RJUserPickerViewControllerDelegate, RJTagPickerViewControllerDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *textDescription;

@property (nonatomic, strong) UIViewController *currentVC;

@property (nonatomic, strong, readonly) RJImagePickerViewController *imageVC;
@property (nonatomic, strong, readonly) RJLocationPickerViewController *locationVC;
@property (nonatomic, strong, readonly) RJTagPickerViewController *tagsVC;

@property (nonatomic, strong) RJManagedObjectUser *selectedCreator;

@end


@implementation RJCreateViewController

#pragma mark - Public Properties

- (BOOL)forSale {
    BOOL forSale = NO;
    RJTemplateManagerType type = [[RJTemplateManager sharedInstance] type];
    switch (type) {
        case kRJTemplateManagerTypeClassifieds:
            forSale = YES;
            break;
        case kRJTemplateManagerTypeCommunity:
            forSale = NO;
            break;
    }
    return forSale;
}

- (CLLocation *)location {
    return self.locationVC.selectedLocation;
}

- (NSString *)locationDescription {
    return self.locationVC.selectedLocationString;
}

- (NSArray *)selectedCreatedTags {
    return self.tagsVC.selectedCreatedTags;
}

- (NSArray *)selectedExistingTags {
    return self.tagsVC.selectedExistingTags;
}

- (NSArray *)selectedImages {
    return self.imageVC.selectedImages;
}

- (RJManagedObjectUser *)creator {
    if (self.selectedCreator) {
        return self.selectedCreator;
    } else {
        return [RJManagedObjectUser currentUser];
    }
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.name = newText;
    return YES;
}

#pragma mark - Private Protocols - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.textDescription = textView.text;
}

#pragma mark - Private Protocols - RJLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerSelectedLocationDidChange:(RJLocationPickerViewController *)locationPickerViewController {
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJImagePickerViewControllerDelegate

- (void)imagePickerViewControllerSelectedImagesDidChange:(RJImagePickerViewController *)imagePickerViewController {
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJTagPickerViewControllerDelegate

- (void)tagPickerViewControllerSelectedTagsDidChange:(RJTagPickerViewController *)tagPickerViewController {
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJUserPickerViewControllerProtocol

- (void)userPickerViewControllerDidCancel:(RJUserPickerViewController *)userPickerViewController {
    [[userPickerViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)userPickerViewControllerDidFinish:(RJUserPickerViewController *)userPickerViewController {
    self.selectedCreator = userPickerViewController.selectedUser;
    [[userPickerViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [self finishPostCreation];
    }];
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        UIViewController *viewController = nil;
        
        CreateSection createSection = indexPath.section;
        switch (createSection) {
            case kDetailsCreateSection:
                if (indexPath.item == 1) {
                    viewController = self.locationVC;
                }
                break;
            case kImagesCreateSection:
                if (indexPath.item == 0) {
                    viewController = self.imageVC;
                }
                break;
            case kTagsCreateSection:
                if (indexPath.item == 0) {
                    viewController = self.tagsVC;
                }
                break;
            case kNumCreateSections:
                break;
        }
        
        if (viewController) {
            [[self navigationController] pushViewController:viewController animated:YES];
        } else {
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return UIEdgeInsetsMake(30.0f, 0.0f, 10.0f, 0.0f);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == kImagesCreateSection) {
        CGFloat height = CGRectGetHeight(collectionView.bounds);
        CGFloat width = height;
        return CGSizeMake(width, height);
    }
    
    if (collectionView.tag == kTagsCreateSection) {
        CGFloat height = CGRectGetHeight(collectionView.bounds);
        CGFloat width = height;
        return CGSizeMake(width, height);
    }
    
    if (collectionView == self.collectionView) {
        CGSize size = CGSizeZero;
        
        CreateSection createSection = indexPath.section;
        switch (createSection) {
            case kDetailsCreateSection: {
                if ((indexPath.item == 0) || (indexPath.item == 1)) {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0f);
                } else {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 140.0f);
                }
                break;
            }
            case kImagesCreateSection:
                if (indexPath.item == 0) {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0f);
                } else {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 100.0f);
                }
                break;
            case kTagsCreateSection:
                if (indexPath.item == 0) {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0f);
                } else {
                    size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 100.0f);
                }
                break;
            case kNumCreateSections:
                break;
        }
        
        return size;
    }
    
    return CGSizeZero;
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView.tag == kImagesCreateSection) {
        return 1;
    }
    
    if (collectionView.tag == kTagsCreateSection) {
        return 1;
    }
    
    if (collectionView == self.collectionView) {
        return kNumCreateSections;
    }
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == kImagesCreateSection) {
        return [self.selectedImages count];
    }
    
    if (collectionView.tag == kTagsCreateSection) {
        return [[self selectedTags] count];
    }
    
    if (collectionView == self.collectionView) {
        NSUInteger numItems = 0;
        
        CreateSection createSection = section;
        switch (createSection) {
            case kDetailsCreateSection:
                numItems = 3;
                break;
            case kImagesCreateSection:
                if ([self.selectedImages count] == 0) {
                    numItems = 1;
                } else {
                    numItems = 2;
                }
                break;
            case kTagsCreateSection:
                if ([[self selectedTags] count] == 0) {
                    numItems = 1;
                } else {
                    numItems = 2;
                }
                break;
            case kNumCreateSections:
                break;
        }
        
        return numItems;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    if (collectionView.tag == kImagesCreateSection) {
        RJGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellID forIndexPath:indexPath];
        cell.image.backgroundColor = styleManager.loadingImageBackgroundColor;
        cell.image.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *image = [self.selectedImages objectAtIndex:indexPath.item];
        [cell updateWithImage:image formatName:kRJPostImageFormatCardSquare16BitBGR displaysLoadingIndicator:NO];
        return cell;
    }
    
    if (collectionView.tag == kTagsCreateSection) {
        RJGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellID forIndexPath:indexPath];
        cell.mask = YES;
        cell.image.backgroundColor = styleManager.loadingImageBackgroundColor;
        cell.image.contentMode = UIViewContentModeScaleAspectFill;
        
        id category = [self.selectedTags objectAtIndex:indexPath.item];
        if ([category isKindOfClass:[RJManagedObjectPostCategory class]]) {
            RJManagedObjectPostCategory *existingCategory = category;
            cell.title.text = existingCategory.name;
            if (existingCategory.image) {
                [cell updateWithImage:existingCategory.image formatName:kRJPostImageFormatCardSquare16BitBGR displaysLoadingIndicator:NO];
            } else {
                cell.image.image = nil;
            }
        } else {
            NSString *createdCategory = category;
            cell.title.text = createdCategory;
            cell.image.image = nil;
        }
        
        return cell;
    }
    
    if (collectionView == self.collectionView) {
        UICollectionViewCell *cell = nil;
        BOOL selectable = YES;
        
        CreateSection createSection = indexPath.section;
        switch (createSection) {
            case kDetailsCreateSection: {
                if (indexPath.item == 0) {
                    RJLabelCell *labelCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJLabelCellID forIndexPath:indexPath];
                    labelCell.style = kRJLabelCellStyleTextField;
                    labelCell.textField.text = self.name;
                    labelCell.textField.delegate = self;
                    labelCell.textField.tintColor = [styleManager tintBlueColor];
                    labelCell.textField.placeholder = NSLocalizedString(@"Title", nil);
                    labelCell.textField.font = [styleManager plainTextFont];
                    labelCell.textField.textColor = [styleManager plainTextColor];
                    labelCell.accessoryView.image = nil;
                    labelCell.topBorder.backgroundColor = [[self class] borderColor];
                    labelCell.bottomBorder.backgroundColor = [[self class] borderColor];
                    cell = labelCell;
                } else if (indexPath.item == 1) {
                    RJLabelCell *labelCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJLabelCellID forIndexPath:indexPath];
                    labelCell.style = kRJLabelCellStyleTextLabel;
                    labelCell.textField.text = nil;
                    labelCell.textLabel.font = [styleManager plainTextFont];
                    labelCell.textLabel.textColor = [styleManager plainTextColor];
                    if (self.locationVC.selectedLocationString) {
                        labelCell.textLabel.text = self.locationVC.selectedLocationString;
                    } else {
                        labelCell.textLabel.text = NSLocalizedString(@"Location", nil);
                    }
                    labelCell.accessoryView.image = [UIImage imageNamed:@"disclosureIndicator"];
                    labelCell.topBorder.backgroundColor = [UIColor clearColor];
                    labelCell.bottomBorder.backgroundColor = [[self class] borderColor];
                    cell = labelCell;
                } else {
                    RJLabelCell *labelCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJLabelCellID forIndexPath:indexPath];
                    labelCell.style = kRJLabelCellStyleTextView;
                    labelCell.textView.text = self.textDescription;
                    labelCell.textView.delegate = self;
                    labelCell.textView.tintColor = [styleManager tintBlueColor];
                    labelCell.textView.placeholder = NSLocalizedString(@"Write a description", nil);
                    labelCell.textView.placeholderTextColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7f];
                    labelCell.textView.font = [styleManager plainTextFont];
                    labelCell.textView.textColor = [styleManager plainTextColor];
                    labelCell.accessoryView.image = nil;
                    labelCell.topBorder.backgroundColor = [UIColor clearColor];
                    labelCell.bottomBorder.backgroundColor = [[self class] borderColor];
                    cell = labelCell;
                }
                break;
            }
            case kImagesCreateSection: {
                if (indexPath.item == 0) {
                    RJLabelCell *labelCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJLabelCellID forIndexPath:indexPath];
                    labelCell.style = kRJLabelCellStyleTextLabel;
                    if (self.post) {
                        labelCell.textLabel.text = NSLocalizedString(@"Add additional images", nil);
                    } else {
                        labelCell.textLabel.text = NSLocalizedString(@"Pick images for your post", nil);
                    }
                    labelCell.textLabel.font = [styleManager plainTextFont];
                    labelCell.textLabel.textColor = [styleManager plainTextColor];
                    labelCell.accessoryView.image = [UIImage imageNamed:@"disclosureIndicator"];
                    labelCell.topBorder.backgroundColor = [[self class] borderColor];
                    labelCell.bottomBorder.backgroundColor = [[self class] borderColor];
                    cell = labelCell;
                } else {
                    RJCollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJCollectionCellID forIndexPath:indexPath];
                    [collectionCell.collection registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellID];
                    [collectionCell.collection reloadData];
                    collectionCell.collection.backgroundColor = [UIColor whiteColor];
                    collectionCell.collection.tag = createSection;
                    collectionCell.collection.dataSource = self;
                    collectionCell.collection.delegate = self;
                    cell = collectionCell;
                }
                break;
            }
            case kTagsCreateSection: {
                if (indexPath.item == 0) {
                    RJLabelCell *labelCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJLabelCellID forIndexPath:indexPath];
                    labelCell.style = kRJLabelCellStyleTextLabel;
                    labelCell.textLabel.font = [styleManager plainTextFont];
                    labelCell.textLabel.textColor = [styleManager plainTextColor];
                    labelCell.textLabel.text = NSLocalizedString(@"Choose tags for your post", nil);
                    labelCell.accessoryView.image = [UIImage imageNamed:@"disclosureIndicator"];
                    labelCell.topBorder.backgroundColor = [[self class] borderColor];
                    labelCell.bottomBorder.backgroundColor = [[self class] borderColor];
                    cell = labelCell;
                } else {
                    RJCollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJCollectionCellID forIndexPath:indexPath];
                    [collectionCell.collection registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellID];
                    [collectionCell.collection reloadData];
                    collectionCell.collection.backgroundColor = [UIColor whiteColor];
                    collectionCell.collection.tag = createSection;
                    collectionCell.collection.dataSource = self;
                    collectionCell.collection.delegate = self;
                    cell = collectionCell;
                }
                break;
            }
            case kNumCreateSections:
                break;
        }
        
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        if (selectable) {
            cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
        } else {
            cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    }
    
    return [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
}

#pragma mark - Private Class Methods

+ (UIColor *)borderColor {
    return [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
}

#pragma mark - Private Instance Methods

- (void)finishPostCreation {
    BOOL isEditingExistingPost = !!self.post;
    
    BOOL hasSelectedLocation;
    RJTemplateManagerType templateType = [[RJTemplateManager sharedInstance] type];
    switch (templateType) {
        case kRJTemplateManagerTypeClassifieds:
            hasSelectedLocation = !!self.locationVC.selectedLocation;
            break;
        case kRJTemplateManagerTypeCommunity:
            hasSelectedLocation = YES;
            break;
    }
    
    BOOL hasSelectedImages = ([self.selectedImages count] != 0);
    BOOL hasSelectedTags = ([[self selectedTags] count] != 0);
    BOOL hasTextDescription = !!self.textDescription;
    BOOL hasName = !!self.name;
    BOOL hasCreator = !!self.creator;
    
    if ((isEditingExistingPost && hasSelectedTags && hasTextDescription && hasName && hasSelectedLocation && hasCreator) ||
        (!isEditingExistingPost && hasSelectedTags && hasTextDescription && hasName && hasSelectedLocation && hasSelectedImages && hasCreator))
    {
        [self.delegate createViewControllerDidFinish:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"All fields are required!", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)cancelButtonPressed:(UIButton *)button {
    [self.delegate createViewControllerDidCancel:self];
}

- (NSArray *)selectedTags {
    NSMutableArray *mutableSelectedTags = [[NSMutableArray alloc] init];
    [mutableSelectedTags addObjectsFromArray:self.selectedCreatedTags];
    [mutableSelectedTags addObjectsFromArray:self.selectedExistingTags];
    return mutableSelectedTags;
}

- (void)doneButtonPressed:(UIButton *)button {
    if ([(RJRemoteObjectUser *)[PFUser currentUser] admin]) {
        RJUserPickerViewController *skeletonPicker = [[RJUserPickerViewController alloc] initWithInitiallySelectedUser:self.selectedCreator];
        skeletonPicker.delegate = self;
        UINavigationController *skeletonPickerNav = [[UINavigationController alloc] initWithRootViewController:skeletonPicker];
        [self presentViewController:skeletonPickerNav animated:YES completion:nil];
    } else {
        [self finishPostCreation];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithPost:(RJManagedObjectPost *)post {
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"createButton"] selectedImage:[UIImage imageNamed:@"createButton"]];
        
        _selectedCreator = post.creator;
        
        _post = post;
        
        _name = post.name;
        _textDescription = post.longDescription;
        
        CLLocation *initiallySelectedLocation = nil;
        if (_post.latitude && _post.longitude) {
            initiallySelectedLocation = [[CLLocation alloc] initWithLatitude:[_post.latitude doubleValue] longitude:[_post.longitude doubleValue]];
        }
        _locationVC = [[RJLocationPickerViewController alloc] initWithInitiallySelectedLocation:initiallySelectedLocation];
        _locationVC.delegate = self;
        
        _imageVC = [[RJImagePickerViewController alloc] initWithInitiallySelectedImages:[_post.images allObjects]];
        _imageVC.pickerDelegate = self;
        
        _tagsVC = [[RJTagPickerViewController alloc] initWithInitiallySelectedExistingTags:[_post.categories allObjects]
                                                              initiallySelectedCreatedTags:nil];
        _tagsVC.pickerDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kRJLabelCellID];
    [self.collectionView registerClass:[RJCollectionCell class] forCellWithReuseIdentifier:kRJCollectionCellID];
    [self.collectionView registerClass:[RJSwitchCell class] forCellWithReuseIdentifier:kRJSwitchCellID];
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.collectionView.alwaysBounceVertical = YES;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelButton"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancel animated:NO];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createButton"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:done animated:NO];
    
    self.navigationItem.title = [NSLocalizedString(@"Create", nil) uppercaseString];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

@end
