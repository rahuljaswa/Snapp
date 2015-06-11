//
//  RJLocationViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 4/17/15.
//
//

#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJLocationViewController.h"
#import "RJStore.h"


@interface RJLocationViewController ()

@property (nonatomic, strong, readonly) CLLocation *location;

@end


@implementation RJLocationViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllPostsWithinMiles:100.0f ofLocation:self.location];
    NSError *error = nil;
    self.posts = [[[RJCoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching posts\n\n%@", [error localizedDescription]);
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllPostsWithinMiles:100.0f ofLocation:self.location completion:^(BOOL success) {
        if (success) {
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectPost *post = [self.posts objectAtIndex:indexPath.row];
    RJFeedViewController *postViewController = [[RJFeedViewController alloc] initWithPost:post];
    [[self navigationController] pushViewController:postViewController animated:YES];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithLocation:(CLLocation *)location locationDescription:(NSString *)locationDescription {
    self = [super init];
    if (self) {
        _location = location;
        self.title = locationDescription;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}

@end
