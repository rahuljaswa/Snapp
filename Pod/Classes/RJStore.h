//
//  RJStore.h
//  Community
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class NSFetchRequest;
@class RJManagedObjectPostCategory;
@class RJManagedObjectPost;
@class RJManagedObjectThread;
@class RJManagedObjectUser;
@class RJRemoteObjectUser;


@interface RJStore : NSObject

+ (NSFetchRequest *)fetchRequestForAllUsersWithSearchString:(NSString *)searchString;
+ (void)refreshAllUsersWithSearchString:(NSString *)searchString completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForCurrentUser;
+ (void)refreshCurrentUser:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllUsers;
+ (void)refreshAllUsers:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllCategories;
+ (void)refreshAllCategoriesWithCompletion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllCategoriesWithSearchString:(NSString *)searchString;
+ (void)refreshAllCategoriesWithSearchString:(NSString *)searchString completion:(void (^)(BOOL success))completion;

+ (void)refreshPost:(RJManagedObjectPost *)post completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsWithSearchString:(NSString *)searchString;
+ (void)refreshAllPostsWithSearchString:(NSString *)searchString completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPosts;
+ (void)refreshAllPostsWithCompletion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsWithinMiles:(CGFloat)miles ofLocation:(CLLocation *)location;
+ (void)refreshAllPostsWithinMiles:(CGFloat)miles ofLocation:(CLLocation *)location completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsForCategory:(RJManagedObjectPostCategory *)category;
+ (void)refreshAllPostsForCategory:(RJManagedObjectPostCategory *)category completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsForCreator:(RJManagedObjectUser *)creator;
+ (void)refreshAllPostsForCreator:(RJManagedObjectUser *)creator completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsForCommenter:(RJManagedObjectUser *)liker;
+ (void)refreshAllPostsForCommenter:(RJManagedObjectUser *)commenter completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllPostsForLiker:(RJManagedObjectUser *)liker;
+ (void)refreshAllPostsForLiker:(RJManagedObjectUser *)liker completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllLikesForUser:(RJManagedObjectUser *)user;
+ (void)refreshAllLikesForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;

+ (NSFetchRequest *)fetchRequestForAllThreadsForUser:(RJManagedObjectUser *)user;
+ (void)refreshAllThreadsForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;

+ (void)refreshAllMessagesForThread:(RJManagedObjectThread *)thread completion:(void (^)(BOOL success))completion;

+ (void)refreshAllLikesAndCommentsForCurrentUserWithCompletion:(void (^)(BOOL success))completion;

// many-to-many user/category relationships
+ (void)refreshAllBlockedUsersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;
+ (void)refreshAllFollowersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;
+ (void)refreshAllFollowingCategoriesForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;
+ (void)refreshAllFollowingUsersForUser:(RJManagedObjectUser *)user completion:(void (^)(BOOL success))completion;
+ (void)refreshAllFollowingUsersForCategory:(RJManagedObjectPostCategory *)category completion:(void (^)(BOOL success))completion;

+ (void)prefetchData;

@end
