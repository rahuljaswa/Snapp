//
//  RJNotificationsViewController.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectUser.h"
#import "RJNotificationCell.h"
#import "RJNotificationsViewController.h"
#import "RJProfileViewController.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJUserImageCacheEntity.h"
#import "UIImageView+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <ActionLabel/ActionLabel.h>

static NSString *const kRJNotificationsViewControllerCellID = @"RJNotificationsViewControllerCellID";


@interface RJNotificationsViewController ()

@property (nonatomic, strong) NSArray *notifications;

@end


@implementation RJNotificationsViewController

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
    if (currentUser) {
        NSMutableArray *notifications = [[NSMutableArray alloc] init];
        
        for (RJManagedObjectPost *post in currentUser.posts) {
            [notifications addObjectsFromArray:[post.likes allObjects]];
            [notifications addObjectsFromArray:[post.comments allObjects]];
        }
        
        [notifications sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [notifications filterUsingPredicate:[NSPredicate predicateWithFormat:@"creator != %@", currentUser]];
        
        self.notifications = notifications;
    } else {
        self.notifications = nil;
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    if ([RJManagedObjectUser currentUser]) {
        [RJStore refreshAllLikesAndCommentsForCurrentUserWithCompletion:^(BOOL success) {
            if (success) {
                [self fetchData];
                [self.tableView reloadData];
            }
            if (completion) {
                completion(success);
            }
        }];
    } else {
        [self fetchData];
        [self.tableView reloadData];
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJNotificationsViewControllerCellID
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static RJNotificationCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJNotificationCell alloc] initWithFrame:CGRectZero];;
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [sizingCell sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
}

#pragma mark - Private Instance Methods

- (void)configureCell:(RJNotificationCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.actionLabel clearRegisteredBlocks];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.actionLabel.font = styleManager.plainTextFont;
    cell.actionLabel.textColor = styleManager.plainTextColor;
    
    id notification = [self.notifications objectAtIndex:indexPath.row];
    
    RJManagedObjectLike *like = nil;
    RJManagedObjectComment *comment = nil;
    RJManagedObjectPost *post = nil;
    RJManagedObjectUser *creator = nil;
    
    if ([notification isKindOfClass:[RJManagedObjectLike class]]) {
        like = (RJManagedObjectLike *)notification;
        post = like.post;
        creator = like.creator;
    } else if ([notification isKindOfClass:[RJManagedObjectComment class]]) {
        comment = (RJManagedObjectComment *)notification;
        post = comment.post;
        creator = comment.creator;
    }
    
    NSAttributedString *attrName;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] init];
    
    if (creator.name) {
        attrName = [[NSAttributedString alloc] initWithString:creator.name
                                                   attributes:styleManager.boldLinkTextAttributes];
        [attrText appendAttributedString:attrName];
    }

    NSRange postNameRange;
    NSString *postText = post.name;
    
    if (postText) {
        NSAttributedString *attrPostText = [[NSAttributedString alloc] initWithString:postText
                                                                           attributes:styleManager.linkTextAttributes];
        if (like) {
            NSString *likedText = NSLocalizedString(@" liked ", nil);
            NSAttributedString *attrLikedText = [[NSAttributedString alloc] initWithString:likedText
                                                                                attributes:styleManager.plainTextAttributes];
            [attrText appendAttributedString:attrLikedText];
            
            postNameRange = NSMakeRange([attrText length], [postText length]);
            [attrText appendAttributedString:attrPostText];
            
            NSAttributedString *attrPeriodText = [[NSAttributedString alloc] initWithString:@"."
                                                                                 attributes:styleManager.plainTextAttributes];
            [attrText appendAttributedString:attrPeriodText];
        } else if (comment) {
            NSString *commentedText = NSLocalizedString(@" commented on ", nil);
            NSAttributedString *attrCommentedText = [[NSAttributedString alloc] initWithString:commentedText
                                                                                    attributes:styleManager.plainTextAttributes];
            [attrText appendAttributedString:attrCommentedText];
            
            postNameRange = NSMakeRange([attrText length], [postText length]);
            
            [attrText appendAttributedString:attrPostText];
            
            NSString *commentText = [NSString stringWithFormat:@": \"%@\".", comment.text];
            NSAttributedString *attrCommentText = [[NSAttributedString alloc] initWithString:commentText
                                                                                  attributes:styleManager.plainTextAttributes];
            [attrText appendAttributedString:attrCommentText];
        }
    }
    
    cell.actionLabel.attributedText = attrText;
    
    [cell.actionLabel registerBlock:^{
        RJFeedViewController *postViewController = [[RJFeedViewController alloc] initWithPost:post];
        [[self navigationController] pushViewController:postViewController animated:YES];
    }
                        forRange:postNameRange
             highlightAttributes:styleManager.highlightedLinkTextAttributes];
    
    [cell.actionLabel registerBlock:^{
        RJProfileViewController *profileViewController = [[RJProfileViewController alloc] initWithUser:creator];
        profileViewController.showsSettingsButton = NO;
        [[self navigationController] pushViewController:profileViewController animated:YES];
    }
                        forRange:NSMakeRange(0, [attrName length])
             highlightAttributes:styleManager.highlightedBoldLinkTextAttributes];
    
    RJManagedObjectImage *profilePicture = creator.image;
    UIImage *placeholder = [UIImage imageNamed:@"userPlaceholderPicture40x40"];
    if (profilePicture) {
        NSURL *url = [NSURL URLWithString:profilePicture.imageURL];
        NSString *objectID = [[creator.objectID URIRepresentation] absoluteString];
        RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url
                                                                                     objectID:objectID];
        
        [cell.imageView setImageEntity:entity
                            formatName:kRJUserImageFormatCard16BitBGR40x40
                           placeholder:placeholder];
    } else {
        cell.imageView.image = placeholder;
    }
}

- (void)currentUserChangedBlockSettings:(NSNotification *)notification {
    [self fetchData];
    [self reloadWithCompletion:nil];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self reloadWithCompletion:^(BOOL success) {
        [refreshControl endRefreshing];
    }];
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"notificationsIcon"] selectedImage:[UIImage imageNamed:@"notificationsIcon"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[RJNotificationCell class] forCellReuseIdentifier:kRJNotificationsViewControllerCellID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentUserChangedBlockSettings:)
                                                 name:kRJUserChangedBlockSettingsNotification
                                               object:[RJManagedObjectUser currentUser]];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
    
    self.navigationItem.title = [NSLocalizedString(@"Notifications", nil) uppercaseString];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

@end
