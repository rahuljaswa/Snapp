//
//  RJHomeViewController.m
//  Community
//

#import "RJCreateViewController.h"
#import "RJFeedsViewController.h"
#import "RJHomeViewController.h"
#import "RJManagedObjectUser.h"
#import "RJNotificationsViewController.h"
#import "RJParseUtils.h"
#import "RJProfileViewController.h"
#import "RJThreadsViewController.h"
#import "RJViewControllerDataSourceProtocol.h"
#import "UIImage+RJAdditions.h"

typedef NS_ENUM(NSUInteger, RJHomeViewControllerPage) {
    kRJHomeViewControllerPageFeeds,
    kRJHomeViewControllerPageNotifications,
    kRJHomeViewControllerPageCreate,
    kRJHomeViewControllerPageThreads,
    kRJHomeViewControllerPageProfile
};


@interface RJHomeViewController () <RJCreateViewControllerDelegate, UITabBarControllerDelegate>

@property (nonatomic, assign) RJHomeViewControllerPage pageForCompletion;

@property (nonatomic, strong, readonly) RJCreateViewController *createPlaceholder;
@property (nonatomic, strong, readonly) RJFeedsViewController *feeds;
@property (nonatomic, strong, readonly) RJNotificationsViewController *notifications;
@property (nonatomic, strong, readonly) RJThreadsViewController *threads;
@property (nonatomic, strong, readonly) RJProfileViewController *profile;

@property (nonatomic, strong, readonly) UISegmentedControl *menu;

@end


@implementation RJHomeViewController

@synthesize createPlaceholder = _createPlaceholder;
@synthesize feeds = _feeds;
@synthesize notifications = _notifications;
@synthesize threads = _threads;
@synthesize profile = _profile;

#pragma mark - Private Properties

- (RJCreateViewController *)createPlaceholder {
    if (!_createPlaceholder) {
        _createPlaceholder = [[RJCreateViewController alloc] initWithPost:nil];
    }
    return _createPlaceholder;
}

- (RJFeedsViewController *)feeds {
    if (!_feeds) {
        _feeds = [[RJFeedsViewController alloc] init];
    }
    return _feeds;
}

- (RJNotificationsViewController *)notifications {
    if (!_notifications) {
        _notifications = [[RJNotificationsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    return _notifications;
}

- (RJThreadsViewController *)threads {
    if (!_threads) {
        _threads = [[RJThreadsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    return _threads;
}

- (RJProfileViewController *)profile {
    if (!_profile) {
        _profile = [[RJProfileViewController alloc] initWithUser:[RJManagedObjectUser currentUser]];
        _profile.showsSettingsButton = YES;
    }
    return _profile;
}

#pragma mark - Private Protocols - RJCreateViewControllerDelegate

- (void)createViewControllerDidCancel:(RJCreateViewController *)createViewController {
    self.selectedIndex = self.pageForCompletion;
    [[createViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)createViewControllerDidFinish:(RJCreateViewController *)createViewController {
    self.selectedIndex = self.pageForCompletion;
    [[createViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [[RJParseUtils sharedInstance] createPostWithName:createViewController.name
                                          longDescription:createViewController.textDescription
                                                   images:createViewController.selectedImages
                                       existingCategories:createViewController.selectedExistingTags
                                        createdCategories:createViewController.selectedCreatedTags
                                                  forSale:createViewController.forSale
                                                 location:createViewController.location
                                      locationDescription:createViewController.locationDescription
                                                  creator:createViewController.creator
                                            remoteSuccess:^(BOOL succeeded)
         {
             if ([self.viewControllers[0] isKindOfClass:[RJFeedsViewController class]]) {
                 [self.feeds reloadWithCompletion:nil];
             }
         }];
    }];
}

#pragma mark - Private Protocols - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UIViewController *selectedRootViewController = [(UINavigationController *)viewController childViewControllers][0];
    
    BOOL shouldSelect = YES;
    
    if ([RJManagedObjectUser currentUser]) {
        if (selectedRootViewController == self.createPlaceholder) {
            RJCreateViewController *createVC = [[RJCreateViewController alloc] initWithPost:nil];
            createVC.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:createVC];
            [self presentViewController:navController animated:YES completion:^{
                self.pageForCompletion = [self pageForNavController:(UINavigationController *)self.selectedViewController];
            }];
            
            shouldSelect = NO;
        }
    } else {
        if ((selectedRootViewController == self.threads) || (selectedRootViewController == self.notifications) || (selectedRootViewController == self.profile) || (selectedRootViewController == self.createPlaceholder)) {
            [self.homeDelegate homeViewController:self wantsAuthenticationWithCompletion:^(BOOL success) {
                if (success) {
                    if (self.selectedIndex != self.pageForCompletion) {
                        self.selectedIndex = self.pageForCompletion;
                    }
                } else {
                    if (self.selectedIndex != kRJHomeViewControllerPageFeeds) {
                        self.selectedIndex = kRJHomeViewControllerPageFeeds;
                    }
                }
            }];
            
            if (selectedRootViewController == self.createPlaceholder) {
                self.pageForCompletion = kRJHomeViewControllerPageFeeds;
            } else {
                self.pageForCompletion = [self pageForNavController:(UINavigationController *)viewController];
            }
            
            shouldSelect = NO;
        }
    }
    return shouldSelect;
}

#pragma mark - Private Instance Methods

- (void)setupViewControllers {
    BOOL hasPreviouslySetupViewController = ([self.viewControllers count] > 0);
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    for (RJHomeViewControllerPage page = 0; page <= kRJHomeViewControllerPageProfile; page++) {
        UIViewController *viewController = nil;
        switch (page) {
            case kRJHomeViewControllerPageCreate:
                if (hasPreviouslySetupViewController) {
                    viewController = self.viewControllers[page];
                } else {
                    viewController = self.createPlaceholder;
                }
                break;
            case kRJHomeViewControllerPageFeeds:
                if (hasPreviouslySetupViewController) {
                    viewController = self.viewControllers[page];
                } else {
                    viewController = self.feeds;
                }
                break;
            case kRJHomeViewControllerPageThreads:
                if (hasPreviouslySetupViewController) {
                    viewController = self.viewControllers[page];
                } else {
                    viewController = self.threads;
                }
                break;
            case kRJHomeViewControllerPageNotifications:
                if (hasPreviouslySetupViewController) {
                    viewController = self.viewControllers[page];
                } else {
                    viewController = self.notifications;
                }
                break;
            case kRJHomeViewControllerPageProfile:
                viewController = self.profile;
                break;
        }
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            [viewControllers addObject:viewController];
        } else {
            viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.0f, 0.0f, -5.0f, 0.0f);
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [viewControllers addObject:navController];
        }
        
    }
    self.viewControllers = viewControllers;
}

- (void)userDidLogIn:(NSNotification *)notification {
    _profile = nil;
    [self setupViewControllers];
}

- (void)userDidLogOut:(NSNotification *)notification {
    self.selectedIndex = kRJHomeViewControllerPageFeeds;
    _profile = nil;
    [self setupViewControllers];
}

- (RJHomeViewControllerPage)pageForNavController:(UINavigationController *)navController {
    UIViewController *childViewController = [navController childViewControllers][0];
    if (childViewController == self.threads) {
        return kRJHomeViewControllerPageThreads;
    } else if (childViewController == self.feeds) {
        return kRJHomeViewControllerPageFeeds;
    } else if (childViewController == self.notifications) {
        return kRJHomeViewControllerPageNotifications;
    } else if (childViewController == self.profile) {
        return kRJHomeViewControllerPageProfile;
    } else {
        return kRJHomeViewControllerPageCreate;
    }
}

- (UIViewController<RJViewControllerDataSourceProtocol> *)viewControllerForPage:(RJHomeViewControllerPage)page {
    UIViewController<RJViewControllerDataSourceProtocol> *viewController = nil;
    switch (page) {
        case kRJHomeViewControllerPageCreate:
            break;
        case kRJHomeViewControllerPageFeeds:
            viewController = self.feeds;
            break;
        case kRJHomeViewControllerPageNotifications:
            viewController = self.notifications;
            break;
        case kRJHomeViewControllerPageProfile:
            viewController = self.profile;
            break;
        case kRJHomeViewControllerPageThreads:
            viewController = self.threads;
            break;
    }
    return viewController;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [[self viewControllerForPage:self.selectedIndex] reloadWithCompletion:^(BOOL success) {
        if (completion) {
            completion(success);
        }
    }];
}

- (void)requestAuthenticationWithCompletion:(void (^)(BOOL))completion {
    [self.homeDelegate homeViewController:self wantsAuthenticationWithCompletion:completion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogIn:) name:kRJUserLoggedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogOut:) name:kRJUserLoggedOutNotification object:nil];

    [self setupViewControllers];
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJHomeViewController *homeViewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        homeViewController = [[RJHomeViewController alloc] initWithNibName:nil bundle:nil];
    });
    return homeViewController;
}

@end
