//
//  RJRemoteObjectCategory.m
//  Community
//

#import "RJRemoteObjectCategory.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectCategory

@dynamic appIdentifier;
@dynamic deleted;
@dynamic name;
@dynamic image;
@dynamic followers;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Category";
}

+ (PFQuery *)query {
    PFQuery *categoryQuery = [super query];
    [categoryQuery whereKey:NSStringFromSelector(@selector(appIdentifier))
                    equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    [categoryQuery whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    return categoryQuery;
}

@end
