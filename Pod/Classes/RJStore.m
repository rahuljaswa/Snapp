//
//  RJStore.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJImageCacheManager.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectFlag.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectThread.h"
#import "RJManagedObjectUser.h"
#import "RJRemoteObjectCategory.h"
#import "RJRemoteObjectComment.h"
#import "RJRemoteObjectFlag.h"
#import "RJRemoteObjectLike.h"
#import "RJRemoteObjectMessage.h"
#import "RJRemoteObjectPost.h"
#import "RJRemoteObjectThread.h"
#import "RJRemoteObjectUser.h"
#import "RJPostImageCacheEntity.h"
#import "RJStore.h"
#import <Parse/Parse.h>
@import CoreLocation.CLLocation;

@implementation RJStore

#pragma mark - Private Class Methods - Query Execution

+ (void)executeQuery:(PFQuery *)query relation:(RJDataMarshallerPFRelation)relation targetUser:(RJRemoteObjectUser *)targetUser targetCategory:(RJRemoteObjectCategory *)targetCategory completion:(void (^)(BOOL success))completion {
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"ERROR -> Unable to fetch objects from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            NSLog(@"SUCCESS -> Fetched objects  from remote");
            [[RJCoreDataManager sharedInstance] marshallPFObjects:objects relation:relation targetUser:targetUser targetCategory:targetCategory completion:^{
                if (completion) {
                    completion(YES);
                }
            }];
        }
    }];
}

#pragma mark - Public Class Methods - All Users

+ (NSFetchRequest *)fetchRequestForAllUsersWithSearchString:(NSString *)searchString {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
    return fetchRequest;
}

+ (void)refreshAllUsersWithSearchString:(NSString *)searchString completion:(void (^)(BOOL))completion {
    PFQuery *userQuery = [RJRemoteObjectUser query];
    userQuery.limit = 15;
    [userQuery whereKey:@"searchableName" containsString:[searchString lowercaseString]];
    [self executeQuery:userQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Current User

+ (NSFetchRequest *)fetchRequestForCurrentUser {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"currentUser == %@", @(YES)];
    return fetchRequest;
}

+ (void)refreshCurrentUser:(void (^)(BOOL))completion {
    PFQuery *userQuery = [RJRemoteObjectUser query];
    [userQuery whereKey:@"objectId" equalTo:[RJRemoteObjectUser currentUser].objectId];
    [self executeQuery:userQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Skeleton Users

+ (NSFetchRequest *)fetchRequestForAllUsers {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"skeleton" ascending:NO]];
    return fetchRequest;
}

+ (void)refreshAllUsers:(void (^)(BOOL))completion {
    PFQuery *query = [RJRemoteObjectUser query];
    [self executeQuery:query relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Categories

+ (NSFetchRequest *)fetchRequestForAllCategories {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PostCategory"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    return fetchRequest;
}

+ (void)refreshAllCategoriesWithCompletion:(void (^)(BOOL))completion {
    PFQuery *categoryQuery = [RJRemoteObjectCategory query];
    categoryQuery.limit = 1000;
    [categoryQuery orderByAscending:@"name"];
    [self executeQuery:categoryQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllCategoriesWithSearchString:(NSString *)searchString {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PostCategory"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
    return fetchRequest;
}

+ (void)refreshAllCategoriesWithSearchString:(NSString *)searchString completion:(void (^)(BOOL))completion {
    PFQuery *categoryQuery = [RJRemoteObjectCategory query];
    categoryQuery.limit = 15;
    [categoryQuery orderByAscending:@"name"];
    [categoryQuery whereKey:@"searchableName" containsString:[searchString lowercaseString]];
    [self executeQuery:categoryQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Posts

+ (void)refreshPost:(RJManagedObjectPost *)post completion:(void (^)(BOOL))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];
    [postQuery whereKey:@"objectId" equalTo:post.objectId];
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsWithSearchString:(NSString *)searchString {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (longDescription CONTAINS[cd] %@)", searchString, searchString];
    return fetchRequest;
}

+ (void)refreshAllPostsWithSearchString:(NSString *)searchString completion:(void (^)(BOOL))completion {
    NSString *lowercaseSearchString = [searchString lowercaseString];
    PFQuery *postNameQuery = [RJRemoteObjectPost query];
    [postNameQuery whereKey:@"searchableName" containsString:lowercaseSearchString];
    PFQuery *postLongDescriptionQuery = [RJRemoteObjectPost query];
    [postLongDescriptionQuery whereKey:@"searchableLongDescription" containsString:lowercaseSearchString];
    
    PFQuery *postQuery = [PFQuery orQueryWithSubqueries:@[postNameQuery, postLongDescriptionQuery]];
    postQuery.limit = 15;
    [postQuery orderByAscending:@"createdAt"];
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPosts {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    return fetchRequest;
}

+ (void)refreshAllPostsWithCompletion:(void (^)(BOOL success))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];
    
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [postQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsWithinMiles:(CGFloat)miles ofLocation:(CLLocation *)location {
    CGFloat distance = miles * 1609.0f * 1.1f;
    CGFloat const radius = 6371009.0f; // Earth radius in meters
    CGFloat meanLatitidue = location.coordinate.latitude * M_PI / 180.0f;
    CGFloat deltaLatitude = distance / radius * 180.0f / M_PI;
    CGFloat deltaLongitude = distance / (radius * cos(meanLatitidue)) * 180.0f / M_PI;
    CGFloat minLatitude = location.coordinate.latitude - deltaLatitude;
    CGFloat maxLatitude = location.coordinate.latitude + deltaLatitude;
    CGFloat minLongitude = location.coordinate.longitude - deltaLongitude;
    CGFloat maxLongitude = location.coordinate.longitude + deltaLongitude;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(%@ <= longitude) AND (longitude <= %@) AND (%@ <= latitude) AND (latitude <= %@)", @(minLongitude), @(maxLongitude), @(minLatitude), @(maxLatitude)];
    return fetchRequest;
}

+ (void)refreshAllPostsWithinMiles:(CGFloat)miles ofLocation:(CLLocation *)location completion:(void (^)(BOOL success))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    [postQuery whereKey:@"location" nearGeoPoint:geoPoint withinMiles:miles];
    
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [postQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsForCategory:(RJManagedObjectPostCategory *)category {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(category == %@)", category];
    return fetchRequest;
}

+ (void)refreshAllPostsForCategory:(RJManagedObjectPostCategory *)category completion:(void (^)(BOOL success))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];
    
    PFQuery *postInnerQuery = [RJRemoteObjectCategory query];
    [postInnerQuery whereKey:NSStringFromSelector(@selector(objectId)) equalTo:category.objectId];
    [postQuery whereKey:@"categories" matchesQuery:postInnerQuery];
    
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [postQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsForCreator:(RJManagedObjectUser *)creator {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(creator == %@)", creator];;
    return fetchRequest;
}

+ (void)refreshAllPostsForCreator:(RJManagedObjectUser *)creator completion:(void (^)(BOOL success))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];

    PFQuery *postInnerQuery = [RJRemoteObjectUser query];
    [postInnerQuery whereKey:@"objectId" equalTo:creator.objectId];
    [postQuery whereKey:@"creator" matchesQuery:postInnerQuery];
    
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [postQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsForCommenter:(RJManagedObjectUser *)liker {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ IN comments.creator", liker];
    return fetchRequest;
}

+ (void)refreshAllPostsForCommenter:(RJManagedObjectUser *)commenter completion:(void (^)(BOOL))completion {
    PFQuery *likeInnerQuery = [RJRemoteObjectUser query];
    [likeInnerQuery whereKey:@"objectId" equalTo:commenter.objectId];
    
    PFQuery *likeQuery = [RJRemoteObjectLike query];
    [likeQuery includeKey:@"creator"];
    [likeQuery whereKey:@"creator" matchesQuery:likeInnerQuery];
    [likeQuery includeKey:@"post"];
    [likeQuery includeKey:@"post.creator"];
    [likeQuery includeKey:@"post.categories"];
    [likeQuery includeKey:@"post.likes"];
    [likeQuery includeKey:@"post.likes.creator"];
    [likeQuery includeKey:@"post.comments"];
    [likeQuery includeKey:@"post.comments.creator"];
    [likeQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:likeQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

+ (NSFetchRequest *)fetchRequestForAllPostsForLiker:(RJManagedObjectUser *)liker {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ IN likes.creator", liker];
    return fetchRequest;
}

+ (void)refreshAllPostsForLiker:(RJManagedObjectUser *)liker completion:(void (^)(BOOL))completion {
    PFQuery *likeInnerQuery = [RJRemoteObjectUser query];
    [likeInnerQuery whereKey:@"objectId" equalTo:liker.objectId];
    
    PFQuery *likeQuery = [RJRemoteObjectLike query];
    [likeQuery includeKey:@"creator"];
    [likeQuery whereKey:@"creator" matchesQuery:likeInnerQuery];
    [likeQuery includeKey:@"post"];
    [likeQuery includeKey:@"post.creator"];
    [likeQuery includeKey:@"post.categories"];
    [likeQuery includeKey:@"post.likes"];
    [likeQuery includeKey:@"post.likes.creator"];
    [likeQuery includeKey:@"post.comments"];
    [likeQuery includeKey:@"post.comments.creator"];
    [likeQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:likeQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Likes

+ (NSFetchRequest *)fetchRequestForAllLikesForUser:(RJManagedObjectUser *)user {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Like"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"creator == %@", user];
    return fetchRequest;
}

+ (void)refreshAllLikesForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL))completion {
    PFQuery *likeInnerQuery = [RJRemoteObjectUser query];
    [likeInnerQuery whereKey:@"objectId" equalTo:user.objectId];
    
    PFQuery *likeQuery = [RJRemoteObjectLike query];
    [likeQuery includeKey:@"creator"];
    [likeQuery whereKey:@"creator" matchesQuery:likeInnerQuery];
    [likeQuery orderByDescending:@"createdAt"];
    
    [self executeQuery:likeQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Threads

+ (NSFetchRequest *)fetchRequestForAllThreadsForUser:(RJManagedObjectUser *)user {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Thread"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(post.creator == %@) OR (contacter == %@)", user, user];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    return fetchRequest;
}

+ (void)refreshAllThreadsForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL))completion {
    PFQuery *postCreatorInnerQueryInnerQuery = [RJRemoteObjectUser query];
    [postCreatorInnerQueryInnerQuery whereKey:NSStringFromSelector(@selector(objectId)) equalTo:user.objectId];
    
    PFQuery *postCreatorInnerQuery = [RJRemoteObjectPost query];
    [postCreatorInnerQuery whereKey:@"creator" matchesQuery:postCreatorInnerQueryInnerQuery];
    
    PFQuery *postCreatorQuery = [RJRemoteObjectThread query];
    [postCreatorQuery whereKey:@"post" matchesQuery:postCreatorInnerQuery];
    
    PFQuery *postContacterInnerQuery = [RJRemoteObjectUser query];
    [postContacterInnerQuery whereKey:NSStringFromSelector(@selector(objectId)) equalTo:user.objectId];
    
    PFQuery *postContacterQuery = [RJRemoteObjectThread query];
    [postContacterQuery whereKey:@"contacter" matchesQuery:postContacterInnerQuery];
    
    PFQuery *threadsQuery = [PFQuery orQueryWithSubqueries:@[postContacterQuery, postCreatorQuery]];
    [threadsQuery includeKey:@"contacter"];
    [threadsQuery includeKey:@"lastMessage"];
    [threadsQuery includeKey:@"readReceipts"];
    [threadsQuery includeKey:@"post"];
    [threadsQuery includeKey:@"post.creator"];
    [threadsQuery includeKey:@"post.categories"];
    [threadsQuery includeKey:@"post.likes"];
    [threadsQuery includeKey:@"post.likes.creator"];
    [threadsQuery includeKey:@"post.comments"];
    [threadsQuery includeKey:@"post.comments.creator"];
    
    [self executeQuery:threadsQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Messages

+ (void)refreshAllMessagesForThread:(RJManagedObjectThread *)thread completion:(void (^)(BOOL))completion {
    [[RJRemoteObjectThread query] getObjectInBackgroundWithId:thread.objectId block:^(PFObject *object, NSError *error) {
        if (object) {
            RJRemoteObjectThread *thread = (RJRemoteObjectThread *)object;
            PFQuery *messagesQuery = [thread.messages query];
            [messagesQuery includeKey:@"sender"];
            [messagesQuery includeKey:@"thread"];
            [messagesQuery includeKey:@"thread.contacter"];
            [messagesQuery includeKey:@"thread.post"];
            [messagesQuery includeKey:@"thread.post.creator"];
            [messagesQuery includeKey:@"thread.post.categories"];
            [messagesQuery includeKey:@"thread.post.likes"];
            [messagesQuery includeKey:@"thread.post.likes.creator"];
            [messagesQuery includeKey:@"thread.post.comments"];
            [messagesQuery includeKey:@"thread.post.comments.creator"];
            [messagesQuery includeKey:@"thread.readReceipts"];
            [messagesQuery includeKey:@"post"];
            [messagesQuery includeKey:@"post.creator"];
            [messagesQuery includeKey:@"post.categories"];
            [messagesQuery includeKey:@"post.likes"];
            [messagesQuery includeKey:@"post.likes.creator"];
            [messagesQuery includeKey:@"post.comments"];
            [messagesQuery includeKey:@"post.comments.creator"];
            
            [self executeQuery:messagesQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
        } else {
            NSLog(@"ERROR -> Unable to fetch thread from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - Public Class Methods - Notifications

+ (void)refreshAllLikesAndCommentsForCurrentUserWithCompletion:(void (^)(BOOL))completion {
    RJRemoteObjectUser *remoteCurrentUser = [RJRemoteObjectUser currentUser];
    
    PFQuery *postQuery = [RJRemoteObjectPost query];
    postQuery.limit = 50;
    [postQuery whereKey:@"creator" equalTo:remoteCurrentUser];
    [postQuery includeKey:@"categories"];
    [postQuery includeKey:@"creator"];
    [postQuery includeKey:@"likes"];
    [postQuery includeKey:@"likes.creator"];
    [postQuery includeKey:@"likes.post"];
    [postQuery includeKey:@"likes.post.categories"];
    [postQuery includeKey:@"likes.post.likes"];
    [postQuery includeKey:@"likes.post.likes.creator"];
    [postQuery includeKey:@"likes.post.comments"];
    [postQuery includeKey:@"likes.post.comments.creator"];
    [postQuery includeKey:@"comments"];
    [postQuery includeKey:@"comments.creator"];
    [postQuery includeKey:@"comments.post"];
    [postQuery includeKey:@"comments.post.categories"];
    [postQuery includeKey:@"comments.post.likes"];
    [postQuery includeKey:@"comments.post.likes.creator"];
    [postQuery includeKey:@"comments.post.comments"];
    [postQuery includeKey:@"comments.post.comments.creator"];
    
    [self executeQuery:postQuery relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:completion];
}

#pragma mark - Public Class Methods - Blocked Users

+ (void)refreshAllBlockedUsersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL))completion {
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            NSLog(@"ERROR -> Unable to fetch objects from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            RJRemoteObjectUser *remoteUser = (RJRemoteObjectUser *)object;
            PFRelation *relation = remoteUser.blockedUsers;
            PFQuery *query = [relation query];
            [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
            [query whereKey:NSStringFromSelector(@selector(communityMemberships)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
            [self executeQuery:query relation:kRJDataMarshallerPFRelationUserBlockedUsers targetUser:remoteUser targetCategory:nil completion:completion];
        }
    }];
}

#pragma mark - Public Class Methods - Categories Followed

+ (void)refreshAllFollowingCategoriesForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL))completion {
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            NSLog(@"ERROR -> Unable to fetch objects from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            RJRemoteObjectUser *remoteUser = (RJRemoteObjectUser *)object;
            PFRelation *relation = remoteUser.followingCategories;
            PFQuery *query = [relation query];
            [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
            [query whereKey:NSStringFromSelector(@selector(appIdentifier)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
            [self executeQuery:query relation:kRJDataMarshallerPFRelationUserFollowingCategories targetUser:remoteUser targetCategory:nil completion:completion];
        }
    }];
}

#pragma mark - Public Class Methods - Followers 

+ (void)refreshAllFollowersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion {
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            NSLog(@"ERROR -> Unable to fetch objects from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            RJRemoteObjectUser *remoteUser = (RJRemoteObjectUser *)object;
            
            PFQuery *query = [RJRemoteObjectUser query];
            [query whereKey:@"followingUsers" equalTo:object];
            [self executeQuery:query relation:kRJDataMarshallerPFRelationUserFollowers targetUser:remoteUser targetCategory:nil completion:completion];
        }
    }];
}

#pragma mark - Public Class Methods - Following Users

+ (void)refreshAllFollowingUsersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL))completion {
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            NSLog(@"ERROR -> Unable to fetch objects from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            RJRemoteObjectUser *remoteUser = (RJRemoteObjectUser *)object;
            PFRelation *relation = remoteUser.followingUsers;
            PFQuery *query = [relation query];
            [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
            [query whereKey:NSStringFromSelector(@selector(communityMemberships)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
            [self executeQuery:query relation:kRJDataMarshallerPFRelationUserFollowingUsers targetUser:remoteUser targetCategory:nil completion:completion];
        }
    }];
}

#pragma mark - Public Class Methods - Category Followers

+ (void)refreshAllFollowingUsersForCategory:(RJManagedObjectPostCategory *)category completion:(void (^)(BOOL))completion {
    [[RJRemoteObjectCategory query] getObjectInBackgroundWithId:category.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            NSLog(@"ERROR -> Unable to fetch object from remote\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        } else {
            RJRemoteObjectCategory *remoteCategory = (RJRemoteObjectCategory *)object;
            PFRelation *relation = remoteCategory.followers;
            PFQuery *query = [relation query];
            [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
            [query whereKey:NSStringFromSelector(@selector(communityMemberships)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
            [self executeQuery:query relation:kRJDataMarshallerPFRelationCategoryFollowingUsers targetUser:nil targetCategory:remoteCategory completion:completion];
        }
    }];
}

#pragma mark - Public Class Methods - Prefetching Data

+ (void)prefetchData {
    [self refreshAllCategoriesWithCompletion:nil];
}

@end
