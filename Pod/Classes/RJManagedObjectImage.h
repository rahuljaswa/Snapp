//
//  RJManagedObjectImage.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class RJManagedObjectPost;
@class RJManagedObjectPostCategory;
@class RJManagedObjectUser;

@interface RJManagedObjectImage : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *imageURL;

@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *posts;
@property (nonatomic, retain) NSSet *users;

@end


@interface RJManagedObjectImage (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)removeCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addPostsObject:(RJManagedObjectPost *)value;
- (void)removePostsObject:(RJManagedObjectPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

- (void)addUsersObject:(RJManagedObjectUser *)value;
- (void)removeUsersObject:(RJManagedObjectUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
