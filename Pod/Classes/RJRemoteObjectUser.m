//
//  RJRemoteObjectUser.m
//  Community
//

#import "RJRemoteObjectUser.h"

@implementation RJRemoteObjectUser


@dynamic blockedUsers;
@dynamic communityMemberships;
@dynamic deleted;
@dynamic followingCategories;
@dynamic followingUsers;
@dynamic image;
@dynamic name;
@dynamic phone;
@dynamic skeleton;
@dynamic twitterDigitsUserID;

@synthesize admin;

#pragma mark - Public Instance Methods

- (BOOL)admin {
    return ([self.phone isEqualToString:@"12222222222"] || [self.phone isEqualToString:@"2222222222"]);
}

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (PFQuery *)query {
    PFQuery *query = [super query];
    [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    [query whereKey:NSStringFromSelector(@selector(communityMemberships)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    return query;
}

@end
