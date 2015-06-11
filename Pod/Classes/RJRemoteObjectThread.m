//
//  RJRemoteObjectThread.m
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import "RJRemoteObjectPost.h"
#import "RJRemoteObjectThread.h"
#import <Parse/PFObject+Subclass.h>


@implementation RJRemoteObjectThread

@dynamic contacter;
@dynamic deleted;
@dynamic lastMessage;
@dynamic messages;
@dynamic post;
@dynamic readReceipts;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Thread";
}

+ (PFQuery *)query {
    PFQuery *threadInnerQuery = [RJRemoteObjectPost query];
    [threadInnerQuery whereKey:@"appIdentifier" equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    
    PFQuery *threadQuery = [super query];
    [threadQuery whereKey:@"post" matchesQuery:threadInnerQuery];
    
    [threadQuery whereKey:NSStringFromSelector(@selector(deleted)) notEqualTo:@(YES)];
    
    return threadQuery;
}

@end
