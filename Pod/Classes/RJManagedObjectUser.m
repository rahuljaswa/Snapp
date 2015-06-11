//
//  RJManagedObjectUser.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectFlag.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"
#import "RJStore.h"

NSString *const kRJUserChangedBlockSettingsNotification = @"RJUserChangedBlockSettingsNotification";
NSString *const kRJUserLoggedInNotification = @"kRJUserLoggedInNotification";
NSString *const kRJUserLoggedOutNotification = @"kRJUserLoggedOutNotification";

@implementation RJManagedObjectUser

@dynamic blockedUsers;
@dynamic comments;
@dynamic createdAt;
@dynamic currentUser;
@dynamic flags;
@dynamic followingCategories;
@dynamic followingUsers;
@dynamic followers;
@dynamic image;
@dynamic likes;
@dynamic messages;
@dynamic name;
@dynamic objectId;
@dynamic posts;
@dynamic readMessages;
@dynamic readThreads;
@dynamic skeleton;
@dynamic threads;

+ (instancetype)currentUser {
    NSFetchRequest *fetchRequest = [RJStore fetchRequestForCurrentUser];
    
    NSError *error = nil;
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    
    return [objects lastObject];
}

@end
