//
//  RJFeedViewController.m
//  Community
//

#import "RJCategoryViewController.h"
#import "RJCollectionViewStickyHeaderFlowLayout.h"
#import "RJCommentsViewController.h"
#import "RJCoreDataManager.h"
#import "RJCreateViewController.h"
#import "RJFeedViewController.h"
#import "RJFlagViewController.h"
#import "RJHomeViewController.h"
#import "RJLocationViewController.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJMessageUserViewController.h"
#import "RJMessagingViewController.h"
#import "RJParseUtils.h"
#import "RJPostCell.h"
#import "RJPostHeaderView.h"
#import "RJProfileViewController.h"
#import "RJRemoteObjectUser.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJUserImageCacheEntity.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+RJAdditions.h"
#import <ActionLabel/ActionLabel.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kRJPostHeaderID = @"RJPostHeaderID";
static NSString *const kRJPostCellID = @"RJPostCellID";

typedef NS_ENUM(NSUInteger, CurrentUserPostOption) {
    kCurrentUserPostOptionEdit,
    kCurrentUserPostOptionDelete,
    kNumCurrentUserPostOptions
};

typedef NS_ENUM(NSUInteger, NonCurrentUserPostOption) {
    kNonCurrentUserPostOptionReport,
    kNumNonCurrentUserPostOptions
};


@interface RJFeedViewController () <RJCommentsViewControllerDelegate, RJCreateViewControllerDelegate, RJFlagViewControllerDelegate, RJMessageUserViewControllerDelegate, RJPostCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) RJManagedObjectPost *deletePendingPost;
@property (strong, nonatomic) RJManagedObjectPost *editPendingPost;
@property (strong, nonatomic) RJManagedObjectPost *flaggedPost;

@property (strong, nonatomic) RJManagedObjectPost *post;

@end


@implementation RJFeedViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    if (self.post) {
        self.posts = @[self.post];
    } else {
        NSError *error = nil;
        NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
        NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllPosts];
        self.posts = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"Error fetching objects\n\n%@", [error localizedDescription]);
        }
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    void (^refreshCompletion)(BOOL) = ^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    };
    
    if (self.post) {
        [RJStore refreshPost:self.post completion:refreshCompletion];
    } else {
        [RJStore refreshAllPostsWithCompletion:refreshCompletion];
    }
}

#pragma mark - Private Protocols - RJCreateViewControllerDelegate

- (void)createViewControllerDidCancel:(RJCreateViewController *)createViewController {
    [[createViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)createViewControllerDidFinish:(RJCreateViewController *)createViewController {
    [[createViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [[RJParseUtils sharedInstance] updatePost:createViewController.post
                                         withName:createViewController.name
                                  longDescription:createViewController.textDescription
                                           images:createViewController.selectedImages
                               existingCategories:createViewController.selectedExistingTags
                                createdCategories:createViewController.selectedCreatedTags
                                          forSale:createViewController.forSale
                                         location:createViewController.location
                              locationDescription:createViewController.locationDescription
                                          creator:createViewController.creator
                                  remoteSuccess:^(BOOL succeeded) {
                                      [self reloadWithCompletion:nil];
                                  }];
    }];
}

#pragma mark - Private Protocols - RJPostCreateCommentsViewControllerDelegate

- (void)commentsViewController:(RJCommentsViewController *)postCell didPressUser:(RJManagedObjectUser *)user {
    RJProfileViewController *profile = [[RJProfileViewController alloc] initWithUser:user];
    profile.showsSettingsButton = NO;
    [[self navigationController] pushViewController:profile animated:YES];
}

- (void)commentsViewController:(RJCommentsViewController *)commentsViewController
    didPressSendButtonWithText:(NSString *)text
{
    [[RJParseUtils sharedInstance] createCommentWithPost:commentsViewController.post
                                                 creator:[RJManagedObjectUser currentUser]
                                                    text:text
                                           remoteSuccess:nil];
    commentsViewController.comments = [self sortedCommentsForPost:commentsViewController.post];
    [self fetchData];
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJFlagViewControllerDelegate

- (void)flagViewControllerDidPressCancelButton:(RJFlagViewController *)flagViewController {
    [[flagViewController navigationController] popViewControllerAnimated:YES];
}

- (void)flagViewController:(RJFlagViewController *)flagViewController didSelectReason:(RJManagedObjectFlagReason)reason {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Sending report", nil)];
    [[RJParseUtils sharedInstance] createFlagWithPost:flagViewController.post
                                              creator:[RJManagedObjectUser currentUser]
                                               reason:reason
                                        remoteSuccess:^(BOOL succeeded)
     {
         if (succeeded) {
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thanks!", nil)];
             [[flagViewController navigationController] popViewControllerAnimated:YES];
         } else {
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Try again", nil)];
         }
     }];
}

#pragma mark - Private Protocols - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (self.flaggedPost) {
        RJFlagViewController *flagViewController = [[RJFlagViewController alloc] initWithPost:self.flaggedPost];
        self.flaggedPost = nil;
        flagViewController.delegate = self;
        [[self navigationController] pushViewController:flagViewController animated:YES];
    } else {
        CurrentUserPostOption option = buttonIndex;
        if (actionSheet.cancelButtonIndex < option) {
            option--;
        }
        
        switch (option) {
            case kCurrentUserPostOptionDelete: {
                [[RJParseUtils sharedInstance] deletePost:self.deletePendingPost remoteSuccess:^(BOOL succeeded) {
                    if (!succeeded) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Delete Failed", nil)];
                    }
                }];
                [self fetchData];
                [self.collectionView reloadData];
                self.deletePendingPost = nil;
                break;
            }
            case kCurrentUserPostOptionEdit: {
                RJCreateViewController *createVC = [[RJCreateViewController alloc] initWithPost:self.editPendingPost];
                self.editPendingPost = nil;
                createVC.delegate = self;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:createVC];
                [self.navigationController presentViewController:navController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Private Protocols - RJMessageUserViewControllerDelegate

- (void)messageUserViewControllerDidPressDoneButton:(RJMessageUserViewController *)messageUserViewController {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Private Protocols - RJPostCellDelegate

- (void)postCell:(RJPostCell *)postCell didPressUser:(RJManagedObjectUser *)user {
    RJProfileViewController *profileViewController = [[RJProfileViewController alloc] initWithUser:user];
    profileViewController.showsSettingsButton = NO;
    [[self navigationController] pushViewController:profileViewController animated:YES];
}

- (void)postCell:(RJPostCell *)postCell didPressCategory:(RJManagedObjectPostCategory *)category {
    RJCategoryViewController *categoryViewController = [[RJCategoryViewController alloc] initWithCategory:category];
    [[self navigationController] pushViewController:categoryViewController animated:YES];
}

- (void)postCellDidPressCommentButton:(RJPostCell *)postCell {
    if ([RJManagedObjectUser currentUser]) {
        RJCommentsViewController *commentVC = [[RJCommentsViewController alloc] initWithPost:postCell.post];
        commentVC.commentsDelegate = self;
        commentVC.comments = [self sortedCommentsForPost:postCell.post];
        commentVC.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:commentVC animated:YES];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (void)postCellDidPressLikeButton:(RJPostCell *)postCell {
    if ([RJManagedObjectUser currentUser]) {
        if (postCell.currentUserLike) {
            [[RJParseUtils sharedInstance] deleteLike:postCell.currentUserLike
                                             withPost:postCell.post
                                        remoteSuccess:nil];
        } else {
            [[RJParseUtils sharedInstance] createLikeWithPost:postCell.post
                                                      creator:[RJManagedObjectUser currentUser]
                                                remoteSuccess:nil];
        }
        [self fetchData];
        [self.collectionView reloadData];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (void)postCell:(RJPostCell *)postCell didPressLocation:(CLLocation *)location locationDescription:(NSString *)locationDescription {
    RJLocationViewController *locationViewController = [[RJLocationViewController alloc] initWithLocation:location locationDescription:locationDescription];
    [[self navigationController] pushViewController:locationViewController animated:YES];
}

- (void)postCellDidPressMessageButton:(RJPostCell *)postCell {
    if ([RJManagedObjectUser currentUser]) {
        RJManagedObjectThread *existingThread = [postCell.post.threads anyObject];
        UIViewController *viewController = nil;
        if (existingThread) {
            viewController = [[RJMessagingViewController alloc] initWithThread:existingThread];
        } else {
            RJMessageUserViewController *messageUserViewController = [[RJMessageUserViewController alloc] initWithPost:postCell.post];
            messageUserViewController.delegate = self;
            viewController = messageUserViewController;
        }
        viewController.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:viewController animated:YES];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (void)postCellDidPressMoreButton:(RJPostCell *)postCell {
    if ([RJManagedObjectUser currentUser]) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        
        BOOL isPostCreatorCurrentUser = [[RJManagedObjectUser currentUser].objectId isEqualToString:postCell.post.creator.objectId];
        BOOL isPostEditableWithAdminRights = [[RJRemoteObjectUser currentUser] admin];
        BOOL isPostEditable = (isPostCreatorCurrentUser || isPostEditableWithAdminRights);
        
        if (isPostEditable) {
            for (CurrentUserPostOption option = 0; option < kNumCurrentUserPostOptions; option++) {
                switch (option) {
                    case kCurrentUserPostOptionDelete:
                        self.deletePendingPost = postCell.post;
                        [titles addObject:NSLocalizedString(@"Delete Post", nil)];
                        break;
                    case kCurrentUserPostOptionEdit:
                        self.editPendingPost = postCell.post;
                        [titles addObject:NSLocalizedString(@"Edit Post", nil)];
                        break;
                    default:
                        break;
                }
            }
        } else {
            for (NonCurrentUserPostOption option = 0; option < kNumNonCurrentUserPostOptions; option++) {
                switch (option) {
                    case kNonCurrentUserPostOptionReport:
                        self.flaggedPost = postCell.post;
                        [titles addObject:NSLocalizedString(@"Report as Inappropriate", nil)];
                        break;
                    default:
                        break;
                }
            }
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *title in titles) { [actionSheet addButtonWithTitle:title]; }
        
        [actionSheet showInView:self.view];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static RJPostCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJPostCell alloc] initWithFrame:CGRectZero];
        sizingCell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGFLOAT_MAX);
    });
    
    [self configureCell:sizingCell indexPath:indexPath];
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    CGSize containerSize = [sizingCell sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    return CGSizeMake(width, containerSize.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJPostHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:kRJPostHeaderID
                                                                         forIndexPath:indexPath];
    
    [header.userName clearRegisteredBlocks];
    header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    header.userName.backgroundColor = [UIColor clearColor];
    
    header.name.font = styleManager.plainTextFont;
    header.name.textColor = styleManager.plainTextColor;
    
    header.bottomBorder.backgroundColor = styleManager.accessoryIconColor;
    
    header.timestamp.font = styleManager.plainTextFont;
    header.timestamp.textColor = styleManager.iconTextColor;
    
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.section];
    
    if (post) {
        header.name.text = post.name;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger comps = (NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
        NSDateComponents *difference = [calendar components:comps
                                                   fromDate:post.createdAt
                                                     toDate:[NSDate date]
                                                    options:0];
        if (difference.day > 0) {
            header.timestamp.text = [NSString stringWithFormat:NSLocalizedString(@"%lud", nil),
                                     (unsigned long)difference.day];
        } else if (difference.hour > 0) {
            header.timestamp.text = [NSString stringWithFormat:NSLocalizedString(@"%luh", nil),
                                     (unsigned long)difference.hour];
        } else if (difference.minute > 0) {
            header.timestamp.text = [NSString stringWithFormat:NSLocalizedString(@"%lum", nil),
                                     (unsigned long)difference.minute];
        } else {
            header.timestamp.text = [NSString stringWithFormat:NSLocalizedString(@"%lus", nil),
                                     (unsigned long)difference.second];
        }
        
        RJManagedObjectUser *creator = post.creator;
        NSString *creatorName = creator.name;
        if (creatorName) {
            NSAttributedString *attrName = [[NSAttributedString alloc] initWithString:creatorName
                                                                           attributes:styleManager.boldLinkTextAttributes];
            header.userName.attributedText = attrName;
            
            NSRange range = NSMakeRange(0, creatorName.length);
            [header.userName registerBlock:^{
                [self postCell:nil didPressUser:creator];
            }
                                  forRange:range
                       highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
        }
        
        UIImage *placeholder = [UIImage imageNamed:@"userPlaceholderPicture40x40"];
        if (creator.image) {
            NSURL *url = [NSURL URLWithString:creator.image.imageURL];
            NSString *objectID = [[creator.objectID URIRepresentation] absoluteString];
            RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url
                                                                                         objectID:objectID];
            
            [header.imageView setImageEntity:entity
                                  formatName:kRJUserImageFormatCard16BitBGR40x40
                                 placeholder:placeholder];
        } else {
            header.imageView.image = placeholder;
        }
    }
    
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    RJPostCell *postCell = (RJPostCell *)cell;
    [postCell.imageCV flashScrollIndicators];
    
    if (indexPath.section < ([self.posts count] - 1)) {
        RJManagedObjectPost *post = [self.posts objectAtIndex:(indexPath.section + 1)];
        NSArray *sortedImages = [post sortedImages];
        if ([sortedImages count] > 0) {
            NSArray *images = [sortedImages objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
            [postCell preloadPostImages:images];
        }
    }
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.posts count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJPostCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJPostCellID forIndexPath:indexPath];
    [self configureCell:postCell indexPath:indexPath];
    return postCell;
}

#pragma mark - Private Instance Methods

- (void)configureCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    RJPostCell *postCell = (RJPostCell *)cell;
    postCell.imageCV.scrollsToTop = NO;
    postCell.detailsTable.scrollsToTop = NO;
    postCell.delegate = self;
    postCell.post = [self.posts objectAtIndex:indexPath.section];
}

- (void)currentUserChangedBlockSettings:(NSNotification *)notification {
    [self fetchData];
    [self reloadWithCompletion:nil];
}

- (void)presentAuthenticationControllerWithCompletion:(void (^)(BOOL success))completion {
    [[RJHomeViewController sharedInstance] requestAuthenticationWithCompletion:completion];
}

- (void)refreshControlTriggered:(UIRefreshControl *)control {
    [self reloadWithCompletion:^(BOOL success) {
        [control endRefreshing];
    }];
}

- (NSArray *)sortedCommentsForPost:(RJManagedObjectPost *)post {
    NSArray *rawComments = [post.comments allObjects];
    return [rawComments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[RJCollectionViewStickyHeaderFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0f;
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 40.0f, 0.0f);
    return [super initWithCollectionViewLayout:layout];
}

- (instancetype)initWithPost:(RJManagedObjectPost *)post {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0f;
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 40.0f, 0.0f);
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentUserChangedBlockSettings:)
                                                 name:kRJUserChangedBlockSettingsNotification
                                               object:[RJManagedObjectUser currentUser]];
    
    self.title = [self.post.name uppercaseString];
    
    self.collectionView.scrollsToTop = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.layer.zPosition = -1;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[RJPostCell class] forCellWithReuseIdentifier:kRJPostCellID];
    [self.collectionView registerClass:[RJPostHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kRJPostHeaderID];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}

@end
