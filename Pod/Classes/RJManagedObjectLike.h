//
//  RJManagedObjectLike.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJManagedObjectLike : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) RJManagedObjectUser *creator;
@property (nonatomic, retain) RJManagedObjectPost *post;

@end
