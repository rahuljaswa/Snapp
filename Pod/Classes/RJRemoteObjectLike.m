//
//  RJRemoteObjectLike.m
//  Community
//

#import "RJRemoteObjectLike.h"
#import "RJRemoteObjectPost.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectLike

@dynamic creator;
@dynamic deleted;
@dynamic post;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Like";
}

+ (PFQuery *)query {
    PFQuery *likeInnerQuery = [RJRemoteObjectPost query];
    [likeInnerQuery whereKey:@"appIdentifier" equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    
    PFQuery *likeQuery = [super query];
    [likeQuery whereKey:@"post" matchesQuery:likeInnerQuery];
    
    [likeQuery whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    
    return likeQuery;
}

@end
