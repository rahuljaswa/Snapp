//
//  RJManagedObjectPost.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class RJManagedObjectComment;
@class RJManagedObjectFlag;
@class RJManagedObjectImage;
@class RJManagedObjectLike;
@class RJManagedObjectPostCategory;
@class RJManagedObjectThread;
@class RJManagedObjectUser;

@interface RJManagedObjectPost : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSNumber *forSale;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSString *locationDescription;
@property (nonatomic, retain) NSString *longDescription;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSNumber *sold;
@property (nonatomic, retain) RJManagedObjectUser *creator;

@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *flags;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) NSSet *threads;

- (NSArray *)sortedImages;

@end


@interface RJManagedObjectPost (CoreDataGeneratedAccessors)

- (void)addFlagsObject:(RJManagedObjectFlag *)value;
- (void)removeFlagsObject:(RJManagedObjectFlag *)value;
- (void)addFlags:(NSSet *)values;
- (void)removeFlags:(NSSet *)values;

- (void)addImagesObject:(RJManagedObjectImage *)value;
- (void)removeImagesObject:(RJManagedObjectImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)removeCategoriesObject:(RJManagedObjectPostCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addCommentsObject:(RJManagedObjectComment *)value;
- (void)removeCommentsObject:(RJManagedObjectComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addLikesObject:(RJManagedObjectLike *)value;
- (void)removeLikesObject:(RJManagedObjectLike *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

- (void)addThreadsObject:(RJManagedObjectThread *)value;
- (void)removeThreadsObject:(RJManagedObjectThread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;

@end
