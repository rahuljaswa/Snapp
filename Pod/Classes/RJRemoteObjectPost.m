//
//  RJRemoteObjectPost.m
//  Community
//

#import "RJRemoteObjectPost.h"
#import "RJRemoteObjectUser.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectPost

@dynamic appIdentifier;
@dynamic categories;
@dynamic comments;
@dynamic creator;
@dynamic deleted;
@dynamic forSale;
@dynamic images;
@dynamic likes;
@dynamic location;
@dynamic locationDescription;
@dynamic longDescription;
@dynamic name;
@dynamic sold;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Post";
}

+ (PFQuery *)query {
    PFQuery *postQuery = [super query];
    [postQuery whereKey:NSStringFromSelector(@selector(appIdentifier))
                equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    [postQuery whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    
    RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
    if (currentUser) {
        PFQuery *peopleBlockedByCurrentUserQuery = [currentUser.blockedUsers query];
        [postQuery whereKey:NSStringFromSelector(@selector(creator)) doesNotMatchQuery:peopleBlockedByCurrentUserQuery];
        
        PFQuery *peopleWhoHaveBlockedCurrentUserQuery = [RJRemoteObjectUser query];
        [peopleWhoHaveBlockedCurrentUserQuery whereKey:NSStringFromSelector(@selector(blockedUsers)) notEqualTo:currentUser];
        [postQuery whereKey:NSStringFromSelector(@selector(creator)) matchesQuery:peopleWhoHaveBlockedCurrentUserQuery];
    }
    
    return postQuery;
}

@end
