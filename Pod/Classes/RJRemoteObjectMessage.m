//
//  RJRemoteObjectMessage.m
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import "RJRemoteObjectMessage.h"


@implementation RJRemoteObjectMessage

@dynamic deleted;
@dynamic readReceipts;
@dynamic sender;
@dynamic text;
@dynamic thread;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Message";
}

@end
