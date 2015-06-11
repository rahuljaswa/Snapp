//
//  RJUserLikesViewController.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectUser.h"
#import "RJStore.h"
#import "RJUserLikesViewController.h"


@interface RJUserLikesViewController ()

@property (nonatomic, strong, readonly) RJManagedObjectUser *liker;

@end


@implementation RJUserLikesViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSMutableSet *posts = [[NSMutableSet alloc] init];
    for (RJManagedObjectLike *like in self.liker.likes) {
        if (like.post) {
            [posts addObject:like.post];
        }
    }
    self.posts = [posts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllPostsForLiker:self.liker completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.row];
    RJFeedViewController *feedViewController = [[RJFeedViewController alloc] initWithPost:post];
    [[self navigationController] pushViewController:feedViewController animated:YES];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithLiker:(RJManagedObjectUser *)liker {
    self = [super init];
    if (self) {
        _liker = liker;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSLocalizedString(@"Likes", nil) uppercaseString];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}

@end
