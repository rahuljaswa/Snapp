//
//  RJManagedObjectPostCategory.h
//  Community
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class RJManagedObjectImage;
@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJManagedObjectPostCategory : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) RJManagedObjectImage *image;

@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *posts;

@end

@interface RJManagedObjectPostCategory (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(RJManagedObjectUser *)value;
- (void)removeFollowersObject:(RJManagedObjectUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addPostsObject:(RJManagedObjectPost *)value;
- (void)removePostsObject:(RJManagedObjectPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
