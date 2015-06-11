//
//  RJRemoteObjectFlag.h
//  Community
//

#import "RJManagedObjectFlag.h"
#import <Parse/Parse.h>


@class RJRemoteObjectPost;
@class RJRemoteObjectUser;

@interface RJRemoteObjectFlag : PFObject <PFSubclassing>

@property (nonatomic, strong) RJRemoteObjectUser *creator;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) RJRemoteObjectPost *post;
@property (nonatomic, assign) RJManagedObjectFlagReason reason;

@end
