//
//  RJUserCommentsViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 2/12/15.
//
//

#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectUser.h"
#import "RJStore.h"
#import "RJUserCommentsViewController.h"


@interface RJUserCommentsViewController ()

@property (nonatomic, strong, readonly) RJManagedObjectUser *commenter;

@end


@implementation RJUserCommentsViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSMutableSet *posts = [[NSMutableSet alloc] init];
    for (RJManagedObjectComment *comment in self.commenter.comments) {
        if (comment.post) {
            [posts addObject:comment.post];
        }
    }
    self.posts = [posts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllPostsForLiker:self.commenter completion:^(BOOL success) {
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

- (instancetype)initWithCommenter:(RJManagedObjectUser *)commenter {
    self = [super init];
    if (self) {
        _commenter = commenter;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSLocalizedString(@"Comments", nil) uppercaseString];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}
@end
