//
//  RJRelationsViewController.m
//  Community
//

#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJRelationsViewController.h"
#import "RJParseUtils.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"

static NSString *const kRJRelationsViewControllerCellID = @"RJRelationsViewControllerCellID";

typedef NS_ENUM(NSUInteger, RJRelationsViewControllerRelationsType) {
    kRJRelationsViewControllerRelationsTypeUser,
    kRJRelationsViewControllerRelationsTypeCategory,
};


@interface RJRelationsViewController ()

@property (nonatomic, assign, readonly) RJRelationsViewControllerCategoryRelationsType categoryRelationType;
@property (nonatomic, assign, readonly) RJRelationsViewControllerUserRelationsType userRelationType;
@property (nonatomic, assign, readonly) RJRelationsViewControllerRelationsType type;

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) RJManagedObjectUser *user;
@property (nonatomic, strong) RJManagedObjectPostCategory *category;

@end


@implementation RJRelationsViewController

@synthesize type = _type;

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSArray *rawData = nil;
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers:
                    rawData = [self.category.followers allObjects];
                    break;
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers:
                    rawData = [self.user.blockedUsers allObjects];
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowers:
                    rawData = [self.user.followers allObjects];
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories:
                    rawData = [self.user.followingCategories allObjects];
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers:
                    rawData = [self.user.followingUsers allObjects];
                    break;
            }
            break;
        }
    }
    
    self.objects = [rawData sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    void (^refreshCompletion)(BOOL) = ^ (BOOL success) {
        if (success) {
            [self fetchData];
            [self.tableView reloadData];
        }
    };
    
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers: {
                    [RJStore refreshAllFollowingUsersForCategory:self.category completion:refreshCompletion];
                    [RJStore refreshAllFollowingUsersForUser:[RJManagedObjectUser currentUser] completion:refreshCompletion];
                    break;
                }
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers: {
                    [RJStore refreshAllBlockedUsersForUser:self.user completion:refreshCompletion];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowers: {
                    [RJStore refreshAllFollowersForUser:self.user completion:refreshCompletion];
                    [RJStore refreshAllFollowersForUser:[RJManagedObjectUser currentUser] completion:refreshCompletion];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories: {
                    [RJStore refreshAllFollowingCategoriesForUser:self.user completion:refreshCompletion];
                    [RJStore refreshAllFollowingCategoriesForUser:[RJManagedObjectUser currentUser] completion:refreshCompletion];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers: {
                    [RJStore refreshAllFollowingUsersForUser:self.user completion:refreshCompletion];
                    [RJStore refreshAllFollowingUsersForUser:[RJManagedObjectUser currentUser] completion:refreshCompletion];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJRelationsViewControllerCellID forIndexPath:indexPath];
    
    UIButton *button = (UIButton *)cell.accessoryView;
    if (!button) {
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
        button.clipsToBounds = YES;
        button.titleLabel.font = styleManager.boldTextFont;
        [button setTitleColor:styleManager.iconTextColor forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:styleManager.buttonBackgroundColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:styleManager.highlightedBackgroundColor] forState:UIControlStateHighlighted];
        button.layer.cornerRadius = 3.0f;
    }

    [self configureTextLabel:cell.textLabel atIndexPath:indexPath];
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if ([object isEqual:[RJManagedObjectUser currentUser]]) {
        cell.accessoryView = nil;
    } else {
        cell.accessoryView = button;
        [self configureButton:button atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Private Instance Methods

- (void)configureButton:(UIButton *)button atIndexPath:(NSIndexPath *)indexPath {
    NSSet *collectionToEvaluate = nil;
    
    NSString *noTitle = nil;
    NSString *yesTitle = nil;
    
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers:
                    collectionToEvaluate = self.category.followers;
                    noTitle = NSLocalizedString(@"Unfollow", nil);
                    yesTitle = NSLocalizedString(@"Follow", nil);
                    break;
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers:
                    collectionToEvaluate = self.user.blockedUsers;
                    noTitle = NSLocalizedString(@"Unblock", nil);
                    yesTitle = NSLocalizedString(@"Block", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowers:
                    collectionToEvaluate = self.user.followers;
                    noTitle = NSLocalizedString(@"Unfollow", nil);
                    yesTitle = NSLocalizedString(@"Follow", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories:
                    collectionToEvaluate = self.user.followingCategories;
                    noTitle = NSLocalizedString(@"Unfollow", nil);
                    yesTitle = NSLocalizedString(@"Follow", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers:
                    collectionToEvaluate = self.user.followingUsers;
                    noTitle = NSLocalizedString(@"Unfollow", nil);
                    yesTitle = NSLocalizedString(@"Follow", nil);
                    break;
            }
            break;
        }
    }
    
    if ([collectionToEvaluate containsObject:[self.objects objectAtIndex:indexPath.row]]) {
        [button setTitle:noTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(noButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button setTitle:yesTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(yesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configureTextLabel:(UILabel *)label atIndexPath:(NSIndexPath *)indexPath {
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexPath.row];
                    label.text = user.name;
                    break;
                }
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexPath.row];
                    label.text = user.name;
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexPath.row];
                    label.text = user.name;
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories: {
                    RJManagedObjectPostCategory *category = [self.objects objectAtIndex:indexPath.row];
                    label.text = category.name;
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexPath.row];
                    label.text = user.name;
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - Private Instance Methods - Handlers

- (void)noButtonPressed:(UIButton *)button {
    NSUInteger indexOfObject = button.tag;
    
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] unfollowUser:user remoteSuccess:nil];
                    break;
                }
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] unblockUser:user remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] unfollowUser:user remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories: {
                    RJManagedObjectPostCategory *category = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] unfollowCategory:category remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] unfollowUser:user remoteSuccess:nil];
                    break;
                }
            }
            break;
        }
    }
    
    [self fetchData];
    [self.tableView reloadData];
}

- (void)yesButtonPressed:(UIButton *)button {
    NSUInteger indexOfObject = button.tag;
    
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] followUser:user remoteSuccess:nil];
                    break;
                }
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] blockUser:user remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] followUser:user remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories: {
                    RJManagedObjectPostCategory *category = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] followCategory:category remoteSuccess:nil];
                    break;
                }
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers: {
                    RJManagedObjectUser *user = [self.objects objectAtIndex:indexOfObject];
                    [[RJParseUtils sharedInstance] followUser:user remoteSuccess:nil];
                    break;
                }
            }
            break;
        }
    }
    
    [self fetchData];
    [self.tableView reloadData];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithCategoryRelationsType:(RJRelationsViewControllerCategoryRelationsType)categoryRelationsType category:(RJManagedObjectPostCategory *)category {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _type = kRJRelationsViewControllerRelationsTypeCategory;
        _categoryRelationType = categoryRelationsType;
        _category = category;
    }
    return self;
}

- (instancetype)initWithUserRelationsType:(RJRelationsViewControllerUserRelationsType)userRelationsType user:(RJManagedObjectUser *)user {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _type = kRJRelationsViewControllerRelationsTypeUser;
        _userRelationType = userRelationsType;
        _user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJRelationsViewControllerCellID];
    
    switch (self.type) {
        case kRJRelationsViewControllerRelationsTypeCategory: {
            switch (self.categoryRelationType) {
                case kRJRelationsViewControllerCategoryRelationsTypeCategoryFollowers:
                    self.title = NSLocalizedString(@"Followers", nil);
                    break;
            }
            break;
        }
        case kRJRelationsViewControllerRelationsTypeUser: {
            switch (self.userRelationType) {
                case kRJRelationsViewControllerUserRelationsTypeBlockedUsers:
                    self.title = NSLocalizedString(@"Blocked Users", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowers:
                    self.title = NSLocalizedString(@"Followers", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingCategories:
                    self.title = NSLocalizedString(@"Tags Following", nil);
                    break;
                case kRJRelationsViewControllerUserRelationsTypeFollowingUsers:
                    self.title = NSLocalizedString(@"Following", nil);
                    break;
            }
            break;
        }
    }
    
    [self reloadWithCompletion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchData];
    [self.tableView reloadData];
}

@end
