//
//  RJCategoryViewController.m
//  Community
//

#import "RJCategoryHeaderView.h"
#import "RJCategoryViewController.h"
#import "RJFeedViewController.h"
#import "RJHomeViewController.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJRelationsViewController.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"

static NSString *const kRJCategoryViewControllerHeaderID = @"RJCategoryViewControllerHeaderID";

static const CGFloat kRJCategoryViewControllerHeaderHeight = 50.0f;


@interface RJCategoryViewController ()

@property (nonatomic, strong) RJManagedObjectPostCategory *category;

@end


@implementation RJCategoryViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSArray *allPosts = [self.category.posts allObjects];
    self.posts = [allPosts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllPostsForCategory:self.category completion:^(BOOL success) {
        if (success) {
            [self.collectionView reloadData];
        }
    }];
    [RJStore refreshAllFollowingUsersForCategory:self.category completion:^(BOOL success) {
        if (success) {
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - Private Protocols - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    if (section == 0) {
        size = CGSizeMake(CGRectGetWidth(collectionView.bounds), kRJCategoryViewControllerHeaderHeight);
    }
    return size;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    RJCategoryHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                     withReuseIdentifier:kRJCategoryViewControllerHeaderID
                                                                            forIndexPath:indexPath];
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    if ([self isFollowing]) {
        [header.headerButton setTitle:NSLocalizedString(@"Unfollow", nil) forState:UIControlStateNormal];
        [header.headerButton addTarget:self action:@selector(unfollowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [header.headerButton setTitle:NSLocalizedString(@"Follow", nil) forState:UIControlStateNormal];
        [header.headerButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [header.headerButton setBackgroundImage:[UIImage imageWithColor:styleManager.buttonBackgroundColor] forState:UIControlStateNormal];
    [header.headerButton setBackgroundImage:[UIImage imageWithColor:styleManager.highlightedBackgroundColor] forState:UIControlStateHighlighted];
    [header.headerButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    header.headerButton.titleLabel.font = styleManager.boldTextFont;
    
    NSAttributedString *normalFollowingTitle = [self titleForCollection:self.category.followers title:NSLocalizedString(@"Followers", nil) highlighted:NO];
    [header.followingButton setAttributedTitle:normalFollowingTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedFollowingTitle = [self titleForCollection:self.category.followers title:NSLocalizedString(@"Followers", nil) highlighted:YES];
    [header.followingButton setAttributedTitle:highlightedFollowingTitle forState:UIControlStateHighlighted];
    [header.followingButton addTarget:self action:@selector(followingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSSet *posts = [NSSet setWithArray:self.posts];
    NSAttributedString *normalPostsTitle = [self titleForCollection:posts title:NSLocalizedString(@"Posts", nil) highlighted:NO];
    [header.postsButton setAttributedTitle:normalPostsTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedPostsTitle = [self titleForCollection:posts title:NSLocalizedString(@"Posts", nil) highlighted:YES];
    [header.postsButton setAttributedTitle:highlightedPostsTitle forState:UIControlStateHighlighted];
    [header.postsButton addTarget:self action:@selector(postsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.row];
    RJFeedViewController *postViewController = [[RJFeedViewController alloc] initWithPost:post];
    [[self navigationController] pushViewController:postViewController animated:YES];
}

#pragma mark - Private Instance Methods

- (void)presentAuthenticationControllerWithCompletion:(void (^)(BOOL))completion {
    [[RJHomeViewController sharedInstance] requestAuthenticationWithCompletion:completion];
}

- (BOOL)isFollowing {
    return [self.category.followers containsObject:[RJManagedObjectUser currentUser]];
}

- (void)followingButtonPressed:(UIButton *)button {
    if ([self.category.followers count] > 0) {
        RJRelationsViewController *followingViewController = [[RJRelationsViewController alloc] initWithCategoryRelationsType:kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers category:self.category];
        [[self navigationController] pushViewController:followingViewController animated:YES];
    }
}

- (void)followButtonPressed:(UIButton *)button {
    if ([RJManagedObjectUser currentUser]) {
        [[RJParseUtils sharedInstance] followCategory:self.category remoteSuccess:nil];
        [self fetchData];
        [self.collectionView reloadData];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (void)unfollowButtonPressed:(UIButton *)button {
    if ([RJManagedObjectUser currentUser]) {
        [[RJParseUtils sharedInstance] unfollowCategory:self.category remoteSuccess:nil];
        [self fetchData];
        [self.collectionView reloadData];
    } else {
        [self presentAuthenticationControllerWithCompletion:nil];
    }
}

- (void)postsButtonPressed:(UIButton *)button {
    if ([self.posts count] > 0) {
        [self.collectionView setContentOffset:CGPointMake(0.0f, kRJCategoryViewControllerHeaderHeight) animated:YES];
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
    
    if (title) {
        NSAttributedString *attrCount = [[NSAttributedString alloc] initWithString:count
                                                                        attributes:countAttr];
        [attrTitle appendAttributedString:attrCount];
        NSAttributedString *attrDisplayTitle = [[NSAttributedString alloc] initWithString:title
                                                                               attributes:titleAttr];
        [attrTitle appendAttributedString:attrDisplayTitle];
    }
    
    return attrTitle;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithCategory:(RJManagedObjectPostCategory *)category {
    self = [super init];
    if (self) {
        _category = category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.category.name uppercaseString];
    
    [self.collectionView registerClass:[RJCategoryHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kRJCategoryViewControllerHeaderID];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}

@end
