//
//  RJRemoteObjectComment.h
//  Community
//

#import <Parse/Parse.h>


@class RJRemoteObjectPost;
@class RJRemoteObjectUser;

@interface RJRemoteObjectComment : PFObject <PFSubclassing>

@property (nonatomic, strong) RJRemoteObjectUser *creator;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) RJRemoteObjectPost *post;
@property (nonatomic, strong) NSString *text;

@end
