//
//  RJThreadsViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import "RJCoreDataManager.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectThread.h"
#import "RJManagedObjectUser.h"
#import "RJMessagingViewController.h"
#import "RJRemoteObjectUser.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJThreadsCell.h"
#import "RJThreadsViewController.h"
#import "RJUserImageCacheEntity.h"
#import "UIImageView+RJAdditions.h"


static NSString *const kRJThreadsViewControllerCellID = @"RJThreadsViewControllerCellID";


@interface RJThreadsViewController ()

@property (nonatomic, strong) NSArray *threads;

@end


@implementation RJThreadsViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
    if (currentUser) {
        NSError *error = nil;
        NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
        NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllThreadsForUser:[RJManagedObjectUser currentUser]];
        self.threads = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"Error fetching threads\n\n%@", [error localizedDescription]);
        }
    } else {
        self.threads = nil;
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
    if (currentUser) {
        [RJStore refreshAllThreadsForUser:currentUser completion:^(BOOL success) {
            if (success) {
                [self fetchData];
                [self.tableView reloadData];
            }
            if (completion) {
                completion(success);
            }
            
        }];
    } else {
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectThread *thread = [self.threads objectAtIndex:indexPath.row];
    RJMessagingViewController *messagingViewController = [[RJMessagingViewController alloc] initWithThread:thread];
    messagingViewController.hidesBottomBarWhenPushed = YES;
    [[self navigationController] pushViewController:messagingViewController animated:YES];
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.threads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJThreadsCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJThreadsViewControllerCellID forIndexPath:indexPath];
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJManagedObjectThread *thread = [self.threads objectAtIndex:indexPath.row];
    
    RJManagedObjectUser *user = nil;
    if ([thread.contacter.objectId isEqualToString:[RJRemoteObjectUser currentUser].objectId]) {
        user = thread.post.creator;
    } else {
        user = thread.contacter;
    }
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = thread.post.name;

    if ([thread.readReceipts containsObject:[RJManagedObjectUser currentUser]]) {
        cell.textLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        cell.textLabel.font = styleManager.plainTextFont;
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        cell.detailTextLabel.font = styleManager.plainTextFont;
    } else {
        cell.textLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.9f];
        cell.textLabel.font = styleManager.boldTextFont;
        cell.detailTextLabel.textColor = cell.textLabel.textColor;
        cell.detailTextLabel.font = styleManager.plainTextFont;
    }
    
    UIImage *placeholder = [UIImage imageNamed:@"userPlaceholderPicture40x40"];
    if (user.image) {
        NSURL *url = [NSURL URLWithString:user.image.imageURL];
        NSString *objectID = [[user.objectID URIRepresentation] absoluteString];
        RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url
                                                                                     objectID:objectID];
        
        [cell.imageView setImageEntity:entity
                            formatName:kRJUserImageFormatCard16BitBGR80x80
                           placeholder:placeholder];
    } else {
        cell.imageView.image = placeholder;
    }
    
    return cell;
}

#pragma mark - Private Instance Methods

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self reloadWithCompletion:^(BOOL success) {
        [refreshControl endRefreshing];
    }];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"messagesIcon"] selectedImage:[UIImage imageNamed:@"messagesIcon"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[RJThreadsCell class] forCellReuseIdentifier:kRJThreadsViewControllerCellID];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
    
    self.navigationItem.title = [NSLocalizedString(@"Messages", nil) uppercaseString];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchData];
    [self.tableView reloadData];
}

@end
