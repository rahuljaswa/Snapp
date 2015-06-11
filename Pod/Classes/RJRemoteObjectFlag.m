//
//  RJRemoteObjectFlag.m
//  Community
//

#import "RJRemoteObjectFlag.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectFlag

@dynamic creator;
@dynamic deleted;
@dynamic post;
@dynamic reason;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Flag";
}

+ (PFQuery *)query {
    PFQuery *query = [super query];
    [query whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    return query;
}

@end
