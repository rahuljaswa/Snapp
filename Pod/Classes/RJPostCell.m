//
//  RJPostCell.m
//  Community
//

#import "RJCommentCell.h"
#import "RJGridCell.h"
#import "RJImageCacheManager.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJPostCell.h"
#import "RJPostImageCacheEntity.h"
#import "RJRemoteObjectUser.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "UIButton+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <ActionLabel/ActionLabel.h>
#import <FastImageCache/FICImageCache.h>

static NSString *const kRJGridCellID = @"RJGridCellID";
static const NSInteger kMaxNumberOfCommentsToDisplay = 5;

typedef NS_ENUM(NSUInteger, DetailsTableSection) {
    kDetailsTableSectionLocation,
    kDetailsTableSectionTags,
    kDetailsTableSectionLikes,
    kDetailsTableSectionLongDescription,
    kDetailsTableSectionComments
};

typedef NS_ENUM(NSUInteger, MoreButtonOption) {
    kMoreButtonOptionReport,
    kNumMoreButtonOptions
};


@interface RJPostCell () <ActionLabelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@property (strong, nonatomic) NSArray *detailsTableSections;

@property (strong, nonatomic, readonly) UIView *buttonsView;
@property (strong, nonatomic, readonly) NSArray *images;
@property (strong, nonatomic, readonly) UIPageControl *pageControl;

@property (strong, nonatomic, readonly) NSMutableArray *fetchingEntities;

@end


@implementation RJPostCell

@synthesize buttonsView = _buttonsView;

#pragma mark - Public Properties

- (void)setPost:(RJManagedObjectPost *)post {
    _post = post;
    
    NSArray *likes = [self.post.likes allObjects];
    NSUInteger indexOfCurrentUser = [likes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RJManagedObjectLike *like = obj;
        return [like.creator.objectId isEqual:[RJManagedObjectUser currentUser].objectId];
    }];
    if (indexOfCurrentUser == NSNotFound) {
        _currentUserLike = nil;
    } else {
        _currentUserLike = [likes objectAtIndex:indexOfCurrentUser];
    }
    
    [self updateLikeButton];
    
    self.messageButton.hidden = [self.post.creator.objectId isEqualToString:[RJRemoteObjectUser currentUser].objectId];
    
    [self reloadDetailsTable];
    
    _images = [post sortedImages];
    NSUInteger numImages = [_images count];
    self.pageControl.numberOfPages = numImages;
    self.pageControl.currentPage = 0;
    
    [self.imageCV reloadData];
}

- (NSArray *)detailsTableSections {
    if (!_detailsTableSections) {
        NSMutableArray *mutableSections = [[NSMutableArray alloc] init];
        if (self.post.locationDescription) {
            [mutableSections addObject:@(kDetailsTableSectionLocation)];
        }
        if ([self.post.likes count] > 0) {
            [mutableSections addObject:@(kDetailsTableSectionLikes)];
        }
        if ([self.post.categories count] > 0) {
            [mutableSections addObject:@(kDetailsTableSectionTags)];
        }
        if (self.post.longDescription) {
            [mutableSections addObject:@(kDetailsTableSectionLongDescription)];
        }
        if ([self.post.comments count] > 0) {
            [mutableSections addObject:@(kDetailsTableSectionComments)];
        }
        _detailsTableSections = mutableSections;
    }
    return _detailsTableSections;
}

#pragma mark - Private Properties

- (UIView *)buttonsView {
    if (!_buttonsView) {
        _buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 36.0f)];
        
        UIView *view = _buttonsView;
        [view addSubview:self.likeButton];
        [view addSubview:self.messageButton];
        [view addSubview:self.moreButton];
        [view addSubview:self.commentButton];
        
        UIView *likeButton = self.likeButton;
        likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *messageButton = self.messageButton;
        messageButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *moreButton = self.moreButton;
        moreButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *commentButton = self.commentButton;
        commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(likeButton, moreButton, commentButton, messageButton);
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[likeButton]-5-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[moreButton]-5-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[commentButton]-5-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[messageButton]-5-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-<=5-[likeButton]-<=4-[commentButton]-<=4-[messageButton]"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[moreButton]-<=5-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
    return _buttonsView;
}

#pragma mark - Private Class Methods - Views

- (UIButton *)buttonWithAction:(SEL)action {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.clipsToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = styleManager.boldTextFont;
    [button setTitleColor:styleManager.iconTextColor forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:styleManager.buttonBackgroundColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:styleManager.highlightedBackgroundColor] forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 3.0f;
    button.contentEdgeInsets = UIEdgeInsetsMake(3.0f, 7.0f, 3.0f, 7.0f);
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 3.0f);
    [button centerWithSpacing:4.0f padding:6.0f];
    button.tintColor = styleManager.iconTextColor;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return button;
}

#pragma mark - Private Instance Methods - Cell

- (void)configureCell:(RJCommentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.tintColor = styleManager.accessoryIconColor;
    
    cell.offsetForImageView = YES;
    
    cell.commentLabel.textCheckingTypes = (NSTextCheckingTypeLink | NSTextCheckingTypeAddress | NSTextCheckingTypePhoneNumber);
    cell.commentLabel.linkAttributes = styleManager.linkTextAttributes;
    cell.commentLabel.activeLinkAttributes = styleManager.highlightedLinkTextAttributes;
    
    [cell.commentLabel clearRegisteredBlocks];
    
    DetailsTableSection detailsSection = [self.detailsTableSections[indexPath.section] integerValue];
    switch (detailsSection) {
        case kDetailsTableSectionComments: {
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage tintableImageNamed:@"commentIcon"];
            } else {
                cell.imageView.image = nil;
            }
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *comments = [[self.post.comments allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSUInteger numComments = [comments count];
            RJManagedObjectComment *comment = nil;
            if (numComments > kMaxNumberOfCommentsToDisplay) {
                if (indexPath.row != 0) {
                    comment = [comments objectAtIndex:(numComments - (kMaxNumberOfCommentsToDisplay - indexPath.row))];
                }
            } else {
                comment = [comments objectAtIndex:indexPath.row];
            }
            
            if (comment) {
                [cell updateWithComment:comment blockForCreator:^(RJManagedObjectUser *creator) {
                    if ([self.delegate respondsToSelector:@selector(postCell:didPressUser:)]) {
                        [self.delegate postCell:self didPressUser:creator];
                    }
                }];
            } else {
                [cell updateWithNumberOfComments:[comments count] blockForSelection:^{
                    if ([self.delegate respondsToSelector:@selector(postCellDidPressCommentButton:)]) {
                        [self.delegate postCellDidPressCommentButton:self];
                    }
                }];
            }
            break;
        }
        case kDetailsTableSectionLongDescription: {
            cell.imageView.image = [UIImage tintableImageNamed:@"feedIcon"];
            if (self.post.longDescription) {
                NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:self.post.longDescription
                                                                               attributes:styleManager.plainTextAttributes];
                cell.commentLabel.attributedText = attrText;
            }
            break;
        }
        case kDetailsTableSectionLikes: {
            cell.imageView.image = [UIImage tintableImageNamed:@"heartFullIcon"];
            
            NSArray *likes = [self.post.likes allObjects];
            NSUInteger numLikes = [self.post.likes count];
            if (numLikes < 10) {
                NSMutableAttributedString *attrLikes = [[NSMutableAttributedString alloc] init];
                for (NSUInteger i = 0; i < numLikes; i++) {
                    RJManagedObjectUser *liker = [[likes objectAtIndex:i] creator];
                    NSString *likerName = liker.name;
                    NSRange newRange = NSMakeRange(attrLikes.length, likerName.length);
                    
                    [cell.commentLabel registerBlock:^{
                        if ([self.delegate respondsToSelector:@selector(postCell:didPressUser:)]) {
                            [self.delegate postCell:self didPressUser:liker];
                        }
                    }
                                            forRange:newRange
                                 highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
                    
                    NSAttributedString *attrLike = [[NSAttributedString alloc] initWithString:likerName
                                                                                   attributes:styleManager.boldLinkTextAttributes];
                    [attrLikes appendAttributedString:attrLike];
                    
                    if (i != (numLikes - 1)) {
                        NSAttributedString *attrComma = [[NSAttributedString alloc] initWithString:@", "
                                                                                        attributes:styleManager.plainTextAttributes];
                        [attrLikes appendAttributedString:attrComma];
                    }
                }
                cell.commentLabel.attributedText = attrLikes;
            } else {
                NSString *likesText = [NSString stringWithFormat:@"%lu likes", (unsigned long)numLikes];
                [cell.commentLabel registerBlock:^{ NSLog(@"%@", likesText); }
                                        forRange:NSMakeRange(0, likesText.length)
                             highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
                cell.commentLabel.attributedText = [[NSAttributedString alloc] initWithString:likesText
                                                                                   attributes:styleManager.boldLinkTextAttributes];
            }
            break;
        }
        case kDetailsTableSectionLocation: {
            cell.imageView.image = [UIImage tintableImageNamed:@"locationButton"];
            cell.commentLabel.attributedText = [[NSAttributedString alloc] initWithString:self.post.locationDescription attributes:styleManager.linkTextAttributes];
            [cell.commentLabel registerBlock:^{
                if ([self.delegate respondsToSelector:@selector(postCell:didPressLocation:locationDescription:)]) {
                    CGFloat latitude = [self.post.latitude floatValue];
                    CGFloat longitude = [self.post.longitude floatValue];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                    [self.delegate postCell:self didPressLocation:location locationDescription:self.post.locationDescription];
                }
            }
                                    forRange:NSMakeRange(0, [self.post.locationDescription length])
                         highlightAttributes:styleManager.highlightedLinkTextAttributes];
            break;
        }
        case kDetailsTableSectionTags: {
            cell.imageView.image = [UIImage tintableImageNamed:@"tagIcon"];
            
            NSArray *categories = [self.post.categories allObjects];
            NSUInteger numCategories = [categories count];
            NSMutableAttributedString *attrCategories = [[NSMutableAttributedString alloc] init];
            for (NSUInteger i = 0; i < numCategories; i++) {
                RJManagedObjectPostCategory *category = [categories objectAtIndex:i];
                NSString *categoryName = category.name;
                
                NSRange newRange = NSMakeRange([attrCategories length], [categoryName length]);
                
                [cell.commentLabel registerBlock:^{
                    if ([self.delegate respondsToSelector:@selector(postCell:didPressCategory:)]) {
                        [self.delegate postCell:self didPressCategory:category];
                    }
                }
                                        forRange:newRange
                             highlightAttributes:styleManager.highlightedLinkTextAttributes];
                
                if (categoryName) {
                    NSAttributedString *attrCategory = [[NSAttributedString alloc] initWithString:categoryName
                                                                                       attributes:styleManager.linkTextAttributes];
                    [attrCategories appendAttributedString:attrCategory];
                }
                
                if (i != (numCategories - 1)) {
                    NSAttributedString *attrComma = [[NSAttributedString alloc] initWithString:@", "
                                                                                    attributes:styleManager.plainTextAttributes];
                    [attrCategories appendAttributedString:attrComma];
                }
            }
            cell.commentLabel.attributedText = attrCategories;
            break;
        }
    }
}

#pragma mark - Private Instance Methods - View Updating

- (void)reloadDetailsTable {
    self.detailsTableSections = nil;
    [self.detailsTable reloadData];
}

- (void)updateLikeButton {
    if (self.currentUserLike) {
        [self.likeButton setTitle:NSLocalizedString(@"Unlike", nil) forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage tintableImageNamed:@"heartFullIcon"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setTitle:NSLocalizedString(@"Like", nil) forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage tintableImageNamed:@"heartEmptyIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark - Private Instance Methods - Handlers

- (void)commentButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(postCellDidPressCommentButton:)]) {
        [self.delegate postCellDidPressCommentButton:self];
    }
}

- (void)likeButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(postCellDidPressLikeButton:)]) {
        [self.delegate postCellDidPressLikeButton:self];
    }
}

- (void)messageButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(postCellDidPressMessageButton:)]) {
        [self.delegate postCellDidPressMessageButton:self];
    }
}

- (void)moreButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(postCellDidPressMoreButton:)]) {
        [self.delegate postCellDidPressMoreButton:self];
    }
}

#pragma mark - Private Protocols - ActionLabelDelegate

- (void)actionLabel:(ActionLabel *)label didSelectLinkWithURL:(NSURL *)url {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
        [application openURL:url];
    }
}

- (void)actionLabel:(ActionLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents {
    NSString *comma = @",";
    NSString *space = @" ";
    
    NSMutableString *address = [[NSMutableString alloc] init];
    
    BOOL needsPrecedingComma = NO;
    NSString *street = [addressComponents valueForKey:NSTextCheckingStreetKey];
    if (street) {
        [address appendString:street];
        needsPrecedingComma = YES;
    }
    NSString *city = [addressComponents valueForKey:NSTextCheckingCityKey];
    if (city) {
        if (needsPrecedingComma) { [address appendString:comma]; }
        [address appendString:space];
        [address appendString:city];
        needsPrecedingComma = YES;
    }
    NSString *state = [addressComponents valueForKey:NSTextCheckingStateKey];
    if (state) {
        if (needsPrecedingComma) { [address appendString:comma]; }
        [address appendString:space];
        [address appendString:state];
        needsPrecedingComma = YES;
    }
    NSString *zip = [addressComponents valueForKey:NSTextCheckingZIPKey];
    if (zip) {
        if (needsPrecedingComma) { [address appendString:comma]; }
        [address appendString:space];
        [address appendString:zip];
        needsPrecedingComma = YES;
    }
    NSString *country = [addressComponents valueForKey:NSTextCheckingCountryKey];
    if (country) {
        if (needsPrecedingComma) { [address appendString:comma]; }
        [address appendString:space];
        [address appendString:country];
    }
    
    NSString *urlStringToEscape = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", address];
    NSString *escapedURLString = [urlStringToEscape stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:escapedURLString];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
        [application openURL:url];
    }
}

- (void)actionLabel:(ActionLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    NSString *escapedPhone = [phoneNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedPhoneURLString = [NSString stringWithFormat:@"tel:%@", escapedPhone];
    NSURL *telURL = [NSURL URLWithString:escapedPhoneURLString];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:telURL]) {
        [application openURL:telURL];
    }
}

#pragma mark - Private Protocols - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static RJCommentCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJCommentCell alloc] initWithFrame:CGRectZero];
        CGFloat commentLeftPadding = 35.0f;
        CGFloat width = (CGRectGetWidth(self.bounds) - commentLeftPadding);
        sizingCell.frame = CGRectMake(0.0f, 0.0f, width, CGFLOAT_MAX);
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [sizingCell sizeThatFits:sizingCell.bounds.size].height;
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.detailsTableSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfRows = 0;
    DetailsTableSection detailsSection = [self.detailsTableSections[section] unsignedIntegerValue];
    if (detailsSection == kDetailsTableSectionComments) {
        NSUInteger numberOfComments = [self.post.comments count];
        numberOfRows = (numberOfComments > kMaxNumberOfCommentsToDisplay) ? kMaxNumberOfCommentsToDisplay : numberOfComments;
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    RJCommentCell *cell = [[RJCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.commentLabel.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sideLength = CGRectGetWidth(collectionView.frame);
    return CGSizeMake(sideLength, sideLength);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.pageControl.currentPage = indexPath.item;
    if (indexPath.item < ([self.images count] - 1)) {
        NSUInteger start = (indexPath.item + 1);
        NSArray *images = [self.images objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, 1)]];
        [self preloadPostImages:images];
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
    RJGridCell *galleryCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellID forIndexPath:indexPath];
    galleryCell.backgroundView.backgroundColor = [[[RJStyleManager sharedInstance] loadingImageBackgroundColor] colorWithAlphaComponent:0.2f];
    galleryCell.clipsToBounds = YES;
    
    NSString *formatName = nil;
    if ([[RJStyleManager sharedInstance] cropsImagesToSquares]) {
        formatName = kRJPostImageFormatCardSquare16BitBGR;
    } else {
        formatName = kRJPostImageFormatCard16BitBGR;
    }
    [galleryCell updateWithImage:[self.images objectAtIndex:indexPath.item] formatName:formatName displaysLoadingIndicator:YES];
    return galleryCell;
}

#pragma mark - Public Class Methods

+ (NSString *)imageFormatNameWithStyleManager:(RJStyleManager *)styleManager {
    NSString *formatName = nil;
    if ([[RJStyleManager sharedInstance] cropsImagesToSquares]) {
        formatName = kRJPostImageFormatCardSquare16BitBGR;
    } else {
        formatName = kRJPostImageFormatCard16BitBGR;
    }
    return formatName;
}

#pragma mark - Private Instance Methods

- (void)cancelFetchingEntities {
    NSString *formatName = [[self class] imageFormatNameWithStyleManager:[RJStyleManager sharedInstance]];
    for (RJPostImageCacheEntity *fetchingEntity in self.fetchingEntities) {
        [[FICImageCache sharedImageCache] cancelImageRetrievalForEntity:fetchingEntity withFormatName:formatName];
    }
    [self.fetchingEntities removeAllObjects];
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [self cancelFetchingEntities];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _fetchingEntities = [[NSMutableArray alloc] init];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumInteritemSpacing = 0.0f;
        layout.minimumLineSpacing = 0.0f;
        _imageCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _imageCV.pagingEnabled = YES;
        _imageCV.backgroundColor = [UIColor whiteColor];
        [_imageCV registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellID];
        _imageCV.alwaysBounceHorizontal = YES;
        _imageCV.dataSource = self;
        _imageCV.delegate = self;
        [self.contentView addSubview:_imageCV];
        
        _likeButton = [self buttonWithAction:@selector(likeButtonPressed:)];
        
        _messageButton = [self buttonWithAction:@selector(messageButtonPressed:)];
        _messageButton.imageEdgeInsets = UIEdgeInsetsZero;
        [_messageButton setImage:[UIImage tintableImageNamed:@"messagesIcon"] forState:UIControlStateNormal];
        [_messageButton setTitle:NSLocalizedString(@"Message", nil) forState:UIControlStateNormal];
        
        _moreButton = [self buttonWithAction:@selector(moreButtonPressed:)];
        _moreButton.imageEdgeInsets = UIEdgeInsetsZero;
        [_moreButton setImage:[UIImage tintableImageNamed:@"optionsIcon"] forState:UIControlStateNormal];
        
        _commentButton = [self buttonWithAction:@selector(commentButtonPressed:)];
        [_commentButton setTitle:NSLocalizedString(@"Comment", nil) forState:UIControlStateNormal];
        [_commentButton setImage:[UIImage tintableImageNamed:@"commentIcon"] forState:UIControlStateNormal];
        
        _detailsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _detailsTable.tableHeaderView = [self buttonsView];
        _detailsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _detailsTable.scrollEnabled = NO;
        _detailsTable.dataSource = self;
        _detailsTable.delegate = self;
        [self.contentView addSubview:_detailsTable];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
        _pageControl.currentPageIndicatorTintColor = [[RJStyleManager sharedInstance] themeColor];
        [self.contentView addSubview:_pageControl];
    }
    return self;
}

- (void)preloadPostImages:(NSArray *)images {
    FICImageCache *imageCache = [FICImageCache sharedImageCache];
    
    NSString *formatName = [[self class] imageFormatNameWithStyleManager:[RJStyleManager sharedInstance]];
    for (id image in images) {
        NSURL *imageURL = nil;
        NSString *objectID = nil;
        if ([image isKindOfClass:[PFFile class]]) {
            PFFile *imageFile = image;
            imageURL = [NSURL URLWithString:imageFile.url];
            objectID = imageFile.url;
        } else if ([image isKindOfClass:[NSString class]]) {
            NSString *imageURLString = image;
            imageURL = [NSURL URLWithString:imageURLString];
            objectID = imageURLString;
        } else if ([image isKindOfClass:[RJManagedObjectImage class]]) {
            RJManagedObjectImage *imageObject = image;
            imageURL = [NSURL URLWithString:imageObject.imageURL];
            objectID = imageObject.imageURL;
        }
        
        if (imageURL && objectID) {
            RJPostImageCacheEntity *entity = [[RJPostImageCacheEntity alloc] initWithPostImageURL:imageURL
                                                                                         objectID:objectID];
            [self.fetchingEntities addObject:entity];
            [imageCache retrieveImageForEntity:entity
                                withFormatName:formatName
                               completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                   [self.fetchingEntities removeObject:entity];
                               }];
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageCV setContentOffset:CGPointZero];
    [self cancelFetchingEntities];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        UIView *detailsTable = self.detailsTable;
        detailsTable.translatesAutoresizingMaskIntoConstraints = NO;

        UIView *pageControl = self.pageControl;
        pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *imageCollectionView = self.imageCV;
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat imageCollectionViewHeight = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        NSDictionary *metrics = @{ @"imageCollectionViewHeight" : @(imageCollectionViewHeight) };
        
        NSDictionary *views = NSDictionaryOfVariableBindings(detailsTable, imageCollectionView, pageControl);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageCollectionView(imageCollectionViewHeight)]-5-[pageControl][detailsTable]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageControl]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageCollectionView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailsTable]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.hasSetupStaticConstraints) { [self updateConstraints]; }
    CGSize newSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    newSize.height += self.detailsTable.contentSize.height;
    return newSize;
}

@end
