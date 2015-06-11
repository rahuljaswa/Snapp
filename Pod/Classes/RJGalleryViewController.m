//
//  RJGalleryViewController.m
//  Community
//

#import "RJCollectionViewStickyHeaderFlowLayout.h"
#import "RJCommentCell.h"
#import "RJCommentsViewController.h"
#import "RJCreateViewController.h"
#import "RJFeedViewController.h"
#import "RJGalleryViewController.h"
#import "RJGridCell.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJProfileViewController.h"
#import "RJPostImageCacheEntity.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJUserImageCacheEntity.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+RJAdditions.h"
#import <ActionLabel/ActionLabel.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kRJGridCellID = @"RJGridCellID";


@implementation RJGalleryViewController

#pragma mark - Private Instance Methods - Cell

- (void)configureCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    RJGridCell *gridCell = (RJGridCell *)cell;
    gridCell.disableDuringLoading = NO;
    gridCell.mask = YES;
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.row];
    
    gridCell.backgroundView.backgroundColor = [[RJStyleManager sharedInstance] loadingImageBackgroundColor];
    
    gridCell.title.text = post.name;
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

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

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGridCell *gridCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellID forIndexPath:indexPath];
    [self configureCell:gridCell indexPath:indexPath];
    
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.item];
    id image = [post.images anyObject];
    if (image) {
        [gridCell updateWithImage:image formatName:kRJPostImageFormatCardSquare16BitBGR displaysLoadingIndicator:NO];
    } else {
        gridCell.image.image = nil;
    }
    
    return gridCell;
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsZero;
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellID];
}

@end
