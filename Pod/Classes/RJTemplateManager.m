//
//  RJTemplateManager.m
//  Pods
//
//  Created by Rahul Jaswa on 4/17/15.
//
//

#import "RJTemplateManager.h"


@implementation RJTemplateManager

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJTemplateManager *_sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[RJTemplateManager alloc] init];
    });
    return _sharedInstance;
}

@end
