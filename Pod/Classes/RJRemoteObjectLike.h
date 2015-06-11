//
//  RJRemoteObjectLike.h
//  Community
//

#import <Parse/Parse.h>


@class RJRemoteObjectPost;
@class RJRemoteObjectUser;

@interface RJRemoteObjectLike : PFObject <PFSubclassing>

@property (nonatomic, strong) RJRemoteObjectUser *creator;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) RJRemoteObjectPost *post;

@end
