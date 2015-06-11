//
//  RJManagedObjectFlag.h
//  Community
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RJManagedObjectFlagReason) {
    RJManagedObjectFlagReasonSpamScam,
    RJManagedObjectFlagReasonSelfHarm,
    RJManagedObjectFlagReasonHarassment,
    RJManagedObjectFlagReasonPrivacy,
    RJManagedObjectFlagReasonIllegal,
    RJManagedObjectFlagReasonViolent,
    RJManagedObjectFlagReasonPornography,
    RJManagedObjectFlagReasonHateful,
    RJManagedObjectFlagReasonIntellectualProperty
};


@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJManagedObjectFlag : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSNumber *reason;
@property (nonatomic, retain) RJManagedObjectUser *creator;
@property (nonatomic, retain) RJManagedObjectPost *post;

@end
