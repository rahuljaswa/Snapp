//
//  RJProfileViewController.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJHomeViewController.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJProfileHeaderView.h"
#import "RJProfileViewController.h"
#import "RJSettingsViewController.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJUserCommentsViewController.h"
#import "RJUserImageCacheEntity.h"
#import "RJUserLikesViewController.h"
#import "RJRelationsViewController.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+RJAdditions.h"
#import <Parse/Parse.h>

static const CGFloat kRJProfileViewControllerHeaderHeight = 146.0f;

typedef NS_ENUM(NSUInteger, ActionSheetTag) {
    kActionSheetTagExport,
    kActionSheetTagEditProfilePicture
};

typedef NS_ENUM(NSUInteger, EditProfilePictureActionSheetOption) {
    kEditProfilePictureActionSheetOptionLibrary,
    kEditProfilePictureActionSheetOptionCamera,
    kNumEditProfilePictureActionSheetOptions
};

typedef NS_ENUM(NSUInteger, ExportActionSheetOption) {
    kExportActionSheetOptionBlock,
    kNumExportActionSheetOptions
};

static NSString *const kRJProfileViewControllerHeaderID = @"RJProfileViewControllerHeaderID";


@interface RJProfileViewController () <RJSettingsViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) RJManagedObjectUser *user;

@end


@implementation RJProfileViewController

#pragma mark - Public Properties

- (UINavigationItem *)navigationItem {
    UINavigationItem *navigationItem = [super navigationItem];
    [self updateNavigationItem:navigationItem];
    return navigationItem;
}

#pragma mark - Private Properties

- (void)setShowsSettingsButton:(BOOL)showsSettingsButton {
    _showsSettingsButton = showsSettingsButton;
    [self updateNavigationItem:self.navigationItem];
}

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSError *error = nil;
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllPostsForCreator:self.user];
    self.posts = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching objects\n\n%@", [error localizedDescription]);
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllPostsForCreator:self.user completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
    
    [RJStore refreshAllFollowingCategoriesForUser:self.user completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
    
    [RJStore refreshAllFollowersForUser:self.user completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
    
    [RJStore refreshAllFollowingUsersForUser:self.user completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - Private Protocols - RJSettingsViewControllerDelegate

- (void)settingsViewControllerDidLogout:(RJSettingsViewController *)settingsViewController {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Protocols - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    ActionSheetTag tag = actionSheet.tag;
    switch (tag) {
        case kActionSheetTagEditProfilePicture: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentViewController:picker animated:NO completion:NULL];
            return;
            break;
        }
        case kActionSheetTagExport: {
            ExportActionSheetOption option = buttonIndex;
            if (actionSheet.cancelButtonIndex < option) {
                option--;
            }
            
            switch (option) {
                case kExportActionSheetOptionBlock: {
                    if ([self isBlocking]) {
                        [[RJParseUtils sharedInstance] unblockUser:self.user remoteSuccess:nil];
                    } else {
                        [[RJParseUtils sharedInstance] blockUser:self.user remoteSuccess:nil];
                    }
                    [self fetchData];
                    [self.collectionView reloadData];
                    
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}

#pragma mark - Private Protocols - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picker presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [[RJParseUtils sharedInstance] updateUser:self.user
                                    withImage:chosenImage
                                remoteSuccess:^(BOOL succeeded) {
                                    if (succeeded) {
                                        [self.collectionView reloadData];
                                    }
                                }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private Protocols - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (section == 0) {
        size = CGSizeMake(CGRectGetWidth(collectionView.bounds), kRJProfileViewControllerHeaderHeight);
    }
    return size;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.item];
    RJFeedViewController *feedViewController = [[RJFeedViewController alloc] initWithPost:post];
    [[self navigationController] pushViewController:feedViewController animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    RJProfileHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                     withReuseIdentifier:kRJProfileViewControllerHeaderID
                                                                            forIndexPath:indexPath];
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    header.name.text = self.user.name;
    
    if ([self.user.currentUser boolValue]) {
        [header.headerButton setTitle:NSLocalizedString(@"Edit Profile Picture", nil) forState:UIControlStateNormal];
        [header.headerButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
        NSSet *currentUserFollowing = [currentUser followingUsers];
        if (currentUserFollowing) {
            
            NSString *buttonTitle = nil;
            SEL buttonSelector = NULL;
            
            if ([currentUserFollowing containsObject:self.user]) {
                buttonTitle = NSLocalizedString(@"Unfollow", nil);
                buttonSelector = @selector(unfollowUserButtonPressed:);
            } else {
                buttonTitle = NSLocalizedString(@"Follow", nil);
                buttonSelector = @selector(followUserButtonPressed:);
            }
            
            [header.headerButton setTitle:buttonTitle forState:UIControlStateNormal];
            [header.headerButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];
        } else if (!currentUser) {
            [header.headerButton setTitle:@"Follow" forState:UIControlStateNormal];
            [header.headerButton addTarget:self action:@selector(presentAuthenticationControllerWithCompletion:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [header.headerButton setTitle:@" " forState:UIControlStateNormal];
        }
    }
    
    [header.headerButton setBackgroundImage:[UIImage imageWithColor:styleManager.buttonBackgroundColor] forState:UIControlStateNormal];
    [header.headerButton setBackgroundImage:[UIImage imageWithColor:styleManager.highlightedBackgroundColor] forState:UIControlStateHighlighted];
    [header.headerButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    header.headerButton.titleLabel.font = styleManager.boldTextFont;

    NSAttributedString *normalFollowingTitle = [self titleForCollection:self.user.followingUsers title:NSLocalizedString(@"Following", nil) highlighted:NO];
    [header.followingButton setAttributedTitle:normalFollowingTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedFollowingTitle = [self titleForCollection:self.user.followingUsers title:NSLocalizedString(@"Following", nil) highlighted:YES];
    [header.followingButton setAttributedTitle:highlightedFollowingTitle forState:UIControlStateHighlighted];
    [header.followingButton addTarget:self action:@selector(followingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSAttributedString *normalFollowersTitle = [self titleForCollection:self.user.followers title:NSLocalizedString(@"Followers", nil) highlighted:NO];
    [header.followersButton setAttributedTitle:normalFollowersTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedFollowersTitle = [self titleForCollection:self.user.followers title:NSLocalizedString(@"Followers", nil) highlighted:YES];
    [header.followersButton setAttributedTitle:highlightedFollowersTitle forState:UIControlStateHighlighted];
    [header.followersButton addTarget:self action:@selector(followersButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSAttributedString *normalCategoriesTitle = [self titleForCollection:self.user.followingCategories title:NSLocalizedString(@"Tags", nil) highlighted:NO];
    [header.categoriesButton setAttributedTitle:normalCategoriesTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedCategoriesTitle = [self titleForCollection:self.user.followingCategories title:NSLocalizedString(@"Tags", nil) highlighted:YES];
    [header.categoriesButton setAttributedTitle:highlightedCategoriesTitle forState:UIControlStateHighlighted];
    [header.categoriesButton addTarget:self action:@selector(categoriesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSAttributedString *normalLikesTitle = [self titleForCollection:self.user.likes title:NSLocalizedString(@"Likes", nil) highlighted:NO];
    [header.likesButton setAttributedTitle:normalLikesTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedLikesTitle = [self titleForCollection:self.user.likes title:NSLocalizedString(@"Likes", nil) highlighted:YES];
    [header.likesButton setAttributedTitle:highlightedLikesTitle forState:UIControlStateHighlighted];
    [header.likesButton addTarget:self action:@selector(likesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSAttributedString *normalCommentsTitle = [self titleForCollection:self.user.comments title:NSLocalizedString(@"Comments", nil) highlighted:NO];
    [header.commentsButton setAttributedTitle:normalCommentsTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedCommentsTitle = [self titleForCollection:self.user.comments title:NSLocalizedString(@"Comments", nil) highlighted:YES];
    [header.commentsButton setAttributedTitle:highlightedCommentsTitle forState:UIControlStateHighlighted];
    [header.commentsButton addTarget:self action:@selector(commentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSAttributedString *normalPostsTitle = [self titleForCollection:self.user.posts title:NSLocalizedString(@"Posts", nil) highlighted:NO];
    [header.postsButton setAttributedTitle:normalPostsTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedPostsTitle = [self titleForCollection:self.user.posts title:NSLocalizedString(@"Posts", nil) highlighted:YES];
    [header.postsButton setAttributedTitle:highlightedPostsTitle forState:UIControlStateHighlighted];
    [header.postsButton addTarget:self action:@selector(postsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *placeholder = [UIImage imageNamed:@"userPlaceholderPicture80x80"];
    if (self.user.image) {
        NSURL *url = [NSURL URLWithString:self.user.image.imageURL];
        NSString *objectID = [[self.user.image.objectID URIRepresentation] absoluteString];
        RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url
                                                                                    objectID:objectID];
        
        [header.image setImageEntity:entity
                          formatName:kRJUserImageFormatCard16BitBGR80x80
                         placeholder:placeholder];
    } else {
        header.image.image = placeholder;
    }
    
    return header;
}

#pragma mark - Private Instance Methods

- (void)refreshControlTriggered:(UIRefreshControl *)control {
    [self reloadWithCompletion:^(BOOL success) {
        [control endRefreshing];
    }];
}

- (BOOL)isBlocking {
    return [[[RJManagedObjectUser currentUser] blockedUsers] containsObject:self.user];
}

- (void)followUserButtonPressed:(UIButton *)button {
    [[RJParseUtils sharedInstance] followUser:self.user remoteSuccess:nil];
    [self fetchData];
    [self.collectionView reloadData];
}

- (void)presentAuthenticationControllerWithCompletion:(void (^)(BOOL completion))completion {
    [[RJHomeViewController sharedInstance] requestAuthenticationWithCompletion:completion];
}

- (void)unfollowUserButtonPressed:(UIButton *)button {
    [[RJParseUtils sharedInstance] unfollowUser:self.user remoteSuccess:nil];
    [self fetchData];
    [self.collectionView reloadData];
}

- (void)editButtonPressed:(UIButton *)button {
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (EditProfilePictureActionSheetOption option = 0; option < kNumEditProfilePictureActionSheetOptions; option++) {
        switch (option) {
            case kEditProfilePictureActionSheetOptionLibrary:
                [titles addObject:NSLocalizedString(@"Library", nil)];
                break;
            case kEditProfilePictureActionSheetOptionCamera:
                [titles addObject:NSLocalizedString(@"Camera", nil)];
                break;
            default:
                break;
        }
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Change profile picture", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.tag = kActionSheetTagEditProfilePicture;
    
    for (NSString *title in titles) { [actionSheet addButtonWithTitle:title]; }
    [actionSheet showInView:self.view];
}

- (void)likesButtonPressed:(UIButton *)button {
    if ([self.user.likes count] > 0) {
        RJUserLikesViewController *likesViewController = [[RJUserLikesViewController alloc] initWithLiker:self.user];
        [[self navigationController] pushViewController:likesViewController animated:YES];
    }
}

- (void)postsButtonPressed:(UIButton *)button {
    if ([self.posts count] > 0) {
        [self.collectionView setContentOffset:CGPointMake(0.0f, kRJProfileViewControllerHeaderHeight) animated:YES];
    }
}

- (void)commentsButtonPressed:(UIButton *)button {
    if ([self.user.comments count] > 0) {
        RJUserCommentsViewController *commentsViewController = [[RJUserCommentsViewController alloc] initWithCommenter:self.user];
        [[self navigationController] pushViewController:commentsViewController animated:YES];
    }
}

- (void)followersButtonPressed:(UIButton *)button {
    if ([self.user.followers count] > 0) {
        RJRelationsViewController *followingViewController = [[RJRelationsViewController alloc] initWithUserRelationsType:kRJRelationsViewControllerUserRelationsTypeFollowers user:self.user];
        [[self navigationController] pushViewController:followingViewController animated:YES];
    }
}

- (void)followingButtonPressed:(UIButton *)button {
    if ([self.user.followingUsers count] > 0) {
        RJRelationsViewController *followingViewController = [[RJRelationsViewController alloc] initWithUserRelationsType:kRJRelationsViewControllerUserRelationsTypeFollowingUsers user:self.user];
        [[self navigationController] pushViewController:followingViewController animated:YES];
    }
}

- (void)categoriesButtonPressed:(UIButton *)button {
    if ([self.user.followingCategories count] > 0) {
        RJRelationsViewController *userRelations = [[RJRelationsViewController alloc] initWithUserRelationsType:kRJRelationsViewControllerUserRelationsTypeFollowingCategories user:self.user];
        [[self navigationController] pushViewController:userRelations animated:YES];
    }
}

- (void)settingsBarButtonItemPressed:(UIBarButtonItem *)barButtonItem {
    RJSettingsViewController *settingsViewController = [[RJSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsViewController.delegate = self;
    [[self navigationController] pushViewController:settingsViewController animated:YES];
}

- (void)exportBarButtonItemPressed:(UIBarButtonItem *)barButtonItem {
    if ([RJManagedObjectUser currentUser]) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        for (ExportActionSheetOption option = 0; option < kNumExportActionSheetOptions; option++) {
            switch (option) {
                case kExportActionSheetOptionBlock: {
                    NSString *format = nil;
                    if ([self isBlocking]) {
                        format = NSLocalizedString(@"Unblock %@", nil);
                    } else {
                        format = NSLocalizedString(@"Block %@", nil);
                    }
                    [titles addObject:[NSString stringWithFormat:format, self.user.name]];
                    break;
                }
                default:
                    break;
            }
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        actionSheet.tag = kActionSheetTagExport;
        
        for (NSString *title in titles) { [actionSheet addButtonWithTitle:title]; }
        
        [actionSheet showInView:self.view];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (NSAttributedString *)titleForCollection:(NSSet *)collection title:(NSString *)title highlighted:(BOOL)highlighted {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    NSString *count = [NSString stringWithFormat:@"%lu\n", (unsigned long)[collection count]];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] init];

    NSDictionary *countAttr;
    NSDictionary *titleAttr;
    if (highlighted) {
        countAttr = styleManager.highlightedBoldTextAttributes;
        titleAttr = styleManager.highlightedDarkGrayTextAttributes;
    } else {
        countAttr = styleManager.boldTextAttributes;
        titleAttr = styleManager.darkGrayTextAttributes;
    }
    
    NSAttributedString *attrCount = [[NSAttributedString alloc] initWithString:count
                                                                    attributes:countAttr];
    [attrTitle appendAttributedString:attrCount];
    NSAttributedString *attrDisplayTitle = [[NSAttributedString alloc] initWithString:title
                                                                           attributes:titleAttr];
    [attrTitle appendAttributedString:attrDisplayTitle];

    return attrTitle;
}

- (void)updateNavigationItem:(UINavigationItem *)navigationItem {
    UIBarButtonItem *rightBarButtonItem = nil;
    if (self.showsSettingsButton) {
        UIImage *settingsImage = [UIImage imageNamed:@"settingsButton"];
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:settingsImage
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(settingsBarButtonItemPressed:)];
    } else {
        if (![self.user isEqual:[RJManagedObjectUser currentUser]]) {
            UIImage *exportImage = [UIImage imageNamed:@"exportButton"];
            rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:exportImage
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(exportBarButtonItemPressed:)];
        }
    }
    [navigationItem setRightBarButtonItem:rightBarButtonItem];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithUser:(RJManagedObjectUser *)user {
    self = [super init];
    if (self) {
        _user = user;
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"userIcon"] selectedImage:[UIImage imageNamed:@"userIcon"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[RJProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kRJProfileViewControllerHeaderID];
    
    if ([self.user.objectId isEqualToString:[RJManagedObjectUser currentUser].objectId]) {
        self.navigationItem.title = [NSLocalizedString(@"Profile", nil) uppercaseString];
    } else {
        self.navigationItem.title = [self.user.name uppercaseString];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.layer.zPosition = -1;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    [self reloadWithCompletion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchData];
    [self.collectionView reloadData];
}

@end
