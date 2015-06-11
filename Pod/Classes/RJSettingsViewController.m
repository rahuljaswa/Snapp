//
//  RJSettingsViewController.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJCreateSkeletonUserViewController.h"
#import "RJManagedObjectUser.h"
#import "RJSettingsViewController.h"
#import "RJRelationsViewController.h"
#import "RJRemoteObjectUser.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Parse/Parse.h>

static NSString *const kRJSettingsViewControllerCellID = @"RJSettingsViewControllerCellID";

typedef NS_ENUM(NSUInteger, RJSettingsSection) {
    kRJSettingsSectionUserInfo,
    kRJSettingsSectionPrivacy,
    kRJSettingsSectionFeedback,
    kRJSettingsSectionLogout,
    kNumRJSettingsSections
};

typedef NS_ENUM(NSUInteger, RJAdminSettingsSection) {
    kRJAdminSettingsSectionSkeleton,
    kNumRJAdminSettingsSections
};

typedef NS_ENUM(NSUInteger, RJAdminSkeletonSectionRow) {
    kRJAdminSkeletonSectionRowCreate,
    kNumRJAdminSkeletonSectionRows
};

typedef NS_ENUM(NSUInteger, RJUserInfoSectionRow) {
    kRJUserInfoSectionRowName,
    kNumRJUserInfoSectionRows
};

typedef NS_ENUM(NSUInteger, RJPrivacySectionRow) {
    kRJPrivacySectionRowBlockedUsers,
    kNumRJPrivacySectionRows
};

typedef NS_ENUM(NSUInteger, RJFeedbackSectionRow) {
    kRJFeedbackSectionRowEmailUs,
    kNumRJFeedbackSectionRows
};

typedef NS_ENUM(NSUInteger, RJLogoutSectionRow) {
    kRJLogoutSectionRowLogout,
    kNumRJLogoutSectionRows
};


@interface RJSettingsViewController () <MFMailComposeViewControllerDelegate>

@end


@implementation RJSettingsViewController

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == kRJSettingsSectionPrivacy) && (indexPath.row == kRJPrivacySectionRowBlockedUsers)) {
        RJRelationsViewController *blockedUsersViewController = [[RJRelationsViewController alloc] initWithUserRelationsType:kRJRelationsViewControllerUserRelationsTypeBlockedUsers user:[RJManagedObjectUser currentUser]];
        [[self navigationController] pushViewController:blockedUsersViewController animated:YES];
    } else if ((indexPath.section == kRJSettingsSectionFeedback) && (indexPath.row == kRJFeedbackSectionRowEmailUs)) {
        MFMailComposeViewController *feedbackViewController = [[MFMailComposeViewController alloc] init];
        feedbackViewController.mailComposeDelegate = self;
        [feedbackViewController setToRecipients:@[@"fastappfeedback@gmail.com"]];
        [feedbackViewController setSubject:[NSString stringWithFormat:@"Feedback (%@)", [[NSBundle mainBundle] bundleIdentifier]]];
        [self presentViewController:feedbackViewController animated:YES completion:nil];
    } else if ((indexPath.section == kRJSettingsSectionLogout) && (indexPath.row == kRJLogoutSectionRowLogout)) {
        RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
        currentUser.currentUser = @NO;
        
        NSError *error = nil;
        if ([[currentUser managedObjectContext] save:&error]) {
            [RJRemoteObjectUser logOut];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRJUserLoggedOutNotification object:nil];
            if ([self.delegate respondsToSelector:@selector(settingsViewControllerDidLogout:)]) {
                [self.delegate settingsViewControllerDidLogout:self];
            }
        } else {
            NSLog(@"Error logging current user out of core data\n\n%@", [error localizedDescription]);
        }
    } else if (indexPath.section >= kNumRJSettingsSections) {
        RJAdminSettingsSection adminSection = (indexPath.section - kNumRJSettingsSections);
        switch (adminSection) {
            case kRJAdminSettingsSectionSkeleton: {
                RJCreateSkeletonUserViewController *createSkeletonViewController = [[RJCreateSkeletonUserViewController alloc] initWithNibName:nil bundle:nil];
                [[self navigationController] pushViewController:createSkeletonViewController animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = kNumRJSettingsSections;
    if ([[RJRemoteObjectUser currentUser] admin]) {
        numberOfSections += kNumRJAdminSettingsSections;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfRows = 0;
    
    RJSettingsSection settingsSection = section;
    switch (settingsSection) {
        case kRJSettingsSectionUserInfo:
            numberOfRows = kNumRJUserInfoSectionRows;
            break;
        case kRJSettingsSectionPrivacy:
            numberOfRows = kNumRJPrivacySectionRows;
            break;
        case kRJSettingsSectionFeedback:
            numberOfRows = kNumRJFeedbackSectionRows;
            break;
        case kRJSettingsSectionLogout:
            numberOfRows = kNumRJLogoutSectionRows;
            break;
        default:
            break;
    }
    
    if (section >= kNumRJSettingsSections) {
        RJAdminSettingsSection adminSection = (section - kNumRJSettingsSections);
        switch (adminSection) {
            case kRJAdminSettingsSectionSkeleton:
                numberOfRows = kNumRJAdminSkeletonSectionRows;
                break;
            default:
                break;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJSettingsViewControllerCellID forIndexPath:indexPath];
    
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosureIndicator"]];
    
    RJSettingsSection settingsSection = indexPath.section;
    switch (settingsSection) {
        case kRJSettingsSectionUserInfo: {
            RJUserInfoSectionRow userInfoRow = indexPath.row;
            switch (userInfoRow) {
                case kRJUserInfoSectionRowName:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = [RJManagedObjectUser currentUser].name;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.accessoryView = nil;
                    break;
                default:
                    break;
            }
            break;
        }
        case kRJSettingsSectionPrivacy: {
            RJPrivacySectionRow privacyRow = indexPath.row;
            switch (privacyRow) {
                case kRJPrivacySectionRowBlockedUsers:
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.text = NSLocalizedString(@"Blocked users", nil);
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    cell.accessoryView = disclosureIndicator;
                    break;
                default:
                    break;
            }
            break;
        }
        case kRJSettingsSectionFeedback: {
            RJFeedbackSectionRow feedbackRow = indexPath.row;
            switch (feedbackRow) {
                case kRJFeedbackSectionRowEmailUs:
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.text = NSLocalizedString(@"Send feedback", nil);
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.accessoryView = nil;
                    break;
                default:
                    break;
            }
            break;
        }
        case kRJSettingsSectionLogout: {
            RJLogoutSectionRow logoutRow = indexPath.row;
            switch (logoutRow) {
                case kRJLogoutSectionRowLogout:
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.text = NSLocalizedString(@"Logout", nil);
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.accessoryView = nil;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    if (indexPath.section >= kNumRJSettingsSections) {
        RJAdminSettingsSection adminSection = (indexPath.section - kNumRJSettingsSections);
        switch (adminSection) {
            case kRJAdminSettingsSectionSkeleton:
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.text = NSLocalizedString(@"Create user", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.accessoryView = disclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Private Protocols

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJSettingsViewControllerCellID];
    self.title = [NSLocalizedString(@"Settings", nil) uppercaseString];
}

@end
