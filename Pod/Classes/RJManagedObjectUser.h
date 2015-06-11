//
//  RJManagedObjectUser.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kRJUserChangedBlockSettingsNotification;
FOUNDATION_EXPORT NSString *const kRJUserLoggedInNotification;
FOUNDATION_EXPORT NSString *const kRJUserLoggedOutNotification;


@class RJManagedObjectComment;
@class RJManagedObjectFlag;
@class RJManagedObjectImage;
@class RJManagedObjectLike;
@class RJManagedObjectMessage;
@class RJManagedObjectPost;
@class RJManagedObjectPostCategory;
@class RJManagedObjectThread;
@class RJManagedObjectUser;

@interface RJManagedObjectUser : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSNumber *currentUser;
@property (nonatomic, retain) RJManagedObjectImage *image;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSNumber *skeleton;

@property (nonatomic, retain) NSSet *blockedUsers;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *flags;
@property (nonatomic, retain) NSSet *followingCategories;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *followingUsers;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *posts;
@property (nonatomic, retain) NSSet *readMessages;
@property (nonatomic, retain) NSSet *readThreads;
@property (nonatomic, retain) NSSet *threads;

+ (instancetype)currentUser;

@end


@interface RJManagedObjectUser (CoreDataGeneratedAccessors)

- (void)addBlockedUsersObject:(RJManagedObjectUser *)value;
- (void)removeBlockedUsersObject:(RJManagedObjectUser *)value;
- (void)addBlockedUsers:(NSSet *)values;
- (void)removeBlockedUsers:(NSSet *)values;

- (void)addCommentsObject:(RJManagedObjectComment *)value;
- (void)removeCommentsObject:(RJManagedObjectComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFlagsObject:(RJManagedObjectFlag *)value;
- (void)removeFlagsObject:(RJManagedObjectFlag *)value;
- (void)addFlags:(NSSet *)values;
- (void)removeFlags:(NSSet *)values;

- (void)addFollowingCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)removeFollowingCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)addFollowingCategories:(NSSet *)values;
- (void)removeFollowingCategories:(NSSet *)values;

- (void)addFollowersObject:(RJManagedObjectUser *)value;
- (void)removeFollowersObject:(RJManagedObjectUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingUsersObject:(RJManagedObjectUser *)value;
- (void)removeFollowingUsersObject:(RJManagedObjectUser *)value;
- (void)addFollowingUsers:(NSSet *)values;
- (void)removeFollowingUsers:(NSSet *)values;

- (void)addLikesObject:(RJManagedObjectLike *)value;
- (void)removeLikesObject:(RJManagedObjectLike *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

- (void)addMessagesObject:(RJManagedObjectMessage *)value;
- (void)removeMessagesObject:(RJManagedObjectMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addPostsObject:(RJManagedObjectPost *)value;
- (void)removePostsObject:(RJManagedObjectPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

- (void)addReadMessagesObject:(RJManagedObjectMessage *)value;
- (void)removeReadMessagesObject:(RJManagedObjectMessage *)value;
- (void)addReadMessages:(NSSet *)values;
- (void)removeReadMessages:(NSSet *)values;

- (void)addReadThreadsObject:(RJManagedObjectThread *)value;
- (void)removeReadThreadsObject:(RJManagedObjectThread *)value;
- (void)addReadThreads:(NSSet *)values;
- (void)removeReadThreads:(NSSet *)values;

- (void)addThreadsObject:(RJManagedObjectThread *)value;
- (void)removeThreadsObject:(RJManagedObjectThread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;

@end
