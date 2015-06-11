//
//  RJRemoteObjectComment.m
//  Community
//

#import "RJRemoteObjectComment.h"
#import "RJRemoteObjectPost.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectComment

@dynamic creator;
@dynamic deleted;
@dynamic post;
@dynamic text;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Comment";
}

+ (PFQuery *)query {
    PFQuery *commentInnerQuery = [RJRemoteObjectPost query];
    [commentInnerQuery whereKey:@"appIdentifier" equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    
    PFQuery *commentQuery = [super query];
    [commentQuery whereKey:@"post" matchesQuery:commentInnerQuery];
    
    [commentQuery whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    
    return commentQuery;
}

@end
