//
//  RJParseUtils.h
//  Community
//

#import "RJRemoteObjectFlag.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@class RJManagedObjectPostCategory;
@class RJManagedObjectLike;
@class RJManagedObjectUser;
@class RJManagedObjectPost;
@class RJManagedObjectThread;

@interface RJParseUtils : NSObject

+ (id)sharedInstance;

- (void)updateUser:(RJManagedObjectUser *)user
         withImage:(UIImage *)image
     remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)markThreadAsRead:(RJManagedObjectThread *)thread remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createNewUserWithName:(NSString *)name image:(UIImage *)image remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createNewThreadForPost:(RJManagedObjectPost *)post initialMessage:(NSString *)initialMessage remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;
- (void)insertNewMessage:(NSString *)message inThread:(RJManagedObjectThread *)thread remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)followCategory:(RJManagedObjectPostCategory *)category remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;
- (void)unfollowCategory:(RJManagedObjectPostCategory *)category remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)followUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;
- (void)unfollowUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)blockUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;
- (void)unblockUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)deletePost:(RJManagedObjectPost *)post remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)deleteLike:(RJManagedObjectLike *)like withPost:(RJManagedObjectPost *)post remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createFlagWithPost:(RJManagedObjectPost *)post creator:(RJManagedObjectUser *)creator reason:(RJManagedObjectFlagReason)reason remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createCommentWithPost:(RJManagedObjectPost *)post creator:(RJManagedObjectUser *)creator text:(NSString *)text remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createLikeWithPost:(RJManagedObjectPost *)post creator:(RJManagedObjectUser *)creator remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)createPostWithName:(NSString *)name longDescription:(NSString *)longDescription images:(NSArray *)images existingCategories:(NSArray *)existingCategories createdCategories:(NSArray *)createdCategories forSale:(BOOL)forSale location:(CLLocation *)location locationDescription:(NSString *)locationDescription creator:(RJManagedObjectUser *)creator remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

- (void)updatePost:(RJManagedObjectPost *)post withName:(NSString *)name longDescription:(NSString *)longDescription images:(NSArray *)images existingCategories:(NSArray *)existingCategories createdCategories:(NSArray *)createdCategories forSale:(BOOL)forSale location:(CLLocation *)location locationDescription:(NSString *)locationDescription creator:(RJManagedObjectUser *)creator remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess;

@end
