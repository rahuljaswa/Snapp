//
//  RJAppDelegate.m
//  Community
//

#import "RJAppDelegate.h"
#import "RJCoreDataManager.h"
#import "RJHomeViewController.h"
#import "RJImageCacheManager.h"
#import "RJManagedObjectUser.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJTemplateManager.h"
#import <FastImageCache/FICImageCache.h>
#import <Parse/Parse.h>


@interface RJAppDelegate () <RJHomeViewControllerDelegate>

@property (strong, nonatomic) RJHomeViewController *homeVC;
@property (strong, nonatomic) RJImageCacheManager *imageCacheManager;

@property (copy, nonatomic) void (^userNotificationsRegistrationCompletion) (void);

@end


@implementation RJAppDelegate

#pragma mark - Public Properties

- (RJStyleManager *)styleManager {
    return [RJStyleManager sharedInstance];
}

- (RJTemplateManager *)templateManager {
    return [RJTemplateManager sharedInstance];
}

#pragma mark - Private Properties

- (RJHomeViewController *)homeVC {
    if (!_homeVC) {
        _homeVC = [RJHomeViewController sharedInstance];
        _homeVC.homeDelegate = self;
    }
    return _homeVC;
}

#pragma mark - Private Protocols - RJHomeViewControllerDelegate

- (void)homeViewController:(RJHomeViewController *)homeViewController wantsAuthenticationWithCompletion:(void (^)(BOOL))completion {
    [self authenticateWithCompletion:completion];
}

#pragma mark - UIApplicationDelegate - Main

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"BYNFdvSQFO99fQsnM7nPqkLfQHD6Vy21CNRr777S"
                  clientKey:@"TT3Xeo1qIAmCoscgkCPGWSZ5FemN43IXXoQu56c5"];
    
    [self setUpFastImageCache];
    [[RJCoreDataManager sharedInstance] setUpCoreData];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    [[RJStyleManager sharedInstance] applyGlobalStylesToWindow:self.window];
    [RJStore refreshAllCategoriesWithCompletion:nil];
    
    self.window.rootViewController = self.homeVC;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([RJManagedObjectUser currentUser]) {
        [self requestNotificationsPermissionsWithCompletion:nil];
    }
    [self clearAppBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.homeVC reloadWithCompletion:nil];
    [RJStore refreshAllCategoriesWithCompletion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - UIApplicationDelegate - Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating current installation with device token: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {}

#pragma mark - Public Protocols - UIApplicationDelegate - User Notification Settings

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (self.userNotificationsRegistrationCompletion) {
        self.userNotificationsRegistrationCompletion();
        self.userNotificationsRegistrationCompletion = nil;
    }
}

#pragma mark - Private Instance Methods - Badge

- (void)clearAppBadge {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error clearing app badge: %@", error);
        }
    }];
}

#pragma mark - Private Instance Methods - Setup

- (void)setUpFastImageCache {
    self.imageCacheManager = [[RJImageCacheManager alloc] init];
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    sharedImageCache.delegate = self.imageCacheManager;
    sharedImageCache.formats = [RJImageCacheManager formats];
}

#pragma mark - Private Instance Methods - Registration

- (void)registerUserNotificationSettingsWithCompletion:(void (^)(void))completion {
    self.userNotificationsRegistrationCompletion = completion;
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeNone | UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    } else if (self.userNotificationsRegistrationCompletion) {
        self.userNotificationsRegistrationCompletion();
        self.userNotificationsRegistrationCompletion = nil;
    }
}

- (void)registerRemoteNotificationSettingsWithCompletion:(void (^)(void))completion {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
}

#pragma mark - Public Instance Methods

- (void)authenticateWithCompletion:(void (^)(BOOL success))completion {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must override authenticateWithCompletion:" userInfo:nil];
}

- (void)requestNotificationsPermissionsWithCompletion:(void (^)(void))completion {
    [self registerUserNotificationSettingsWithCompletion:^{
        [self registerRemoteNotificationSettingsWithCompletion:nil];
        if (completion) {
            completion();
        }
    }];
}

@end
