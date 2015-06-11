//
//  RJManagedObjectComment.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJManagedObjectComment : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) RJManagedObjectUser *creator;
@property (nonatomic, retain) RJManagedObjectPost *post;

@end
