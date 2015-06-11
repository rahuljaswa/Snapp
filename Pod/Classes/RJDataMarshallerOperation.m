//
//  RJDataMarshallerOperation.m
//  Pods
//
//  Created by Rahul Jaswa on 3/12/15.
//
//

#import "RJDataMarshaller.h"
#import "RJDataMarshallerOperation.h"

typedef NS_ENUM(NSUInteger, RJDataMarshallerOperationState) {
    kRJDataMarshallerOperationStateNotStarted,
    kRJDataMarshallerOperationStateExecuting,
    kRJDataMarshallerOperationStateFinished
};


@interface RJDataMarshallerOperation ()

@property (nonatomic, strong, readonly) NSArray *pfObjects;
@property (nonatomic, assign) RJDataMarshallerPFRelation pfRelation;
@property (nonatomic, strong) RJRemoteObjectCategory *targetCategory;
@property (nonatomic, strong) RJRemoteObjectUser *targetUser;

@property (nonatomic, assign) RJDataMarshallerOperationState state;

@end


@implementation RJDataMarshallerOperation

#pragma mark - Private Properties

- (void)setState:(RJDataMarshallerOperationState)state {
    if (_state != state) {
        if (state == kRJDataMarshallerOperationStateNotStarted) {
            _state = state;
            return;
        }
        
        NSString *keyPath = nil;
        if (state == kRJDataMarshallerOperationStateExecuting) {
            keyPath = NSStringFromSelector(@selector(isExecuting));
        } else if (state == kRJDataMarshallerOperationStateFinished) {
            keyPath = NSStringFromSelector(@selector(isFinished));
        }
        
        [self willChangeValueForKey:keyPath];
        _state = state;
        [self didChangeValueForKey:keyPath];
    }
}

#pragma mark - Public Instance Methods

- (void)start {
    if ([self isCancelled]) {
        self.state = kRJDataMarshallerOperationStateFinished;
        return;
    }
    
    self.state = kRJDataMarshallerOperationStateExecuting;
    
    [RJDataMarshaller updateOrCreateObjectsWithPFObjects:self.pfObjects relation:self.pfRelation targetCategory:self.targetCategory targetUser:self.targetUser completion:^{
        self.state = kRJDataMarshallerOperationStateFinished;
    }];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return (self.state == kRJDataMarshallerOperationStateExecuting);
}

- (BOOL)isFinished {
    return (self.state == kRJDataMarshallerOperationStateFinished);
}

- (instancetype)initWithPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetCategory:(RJRemoteObjectCategory *)targetCategory targetUser:(RJRemoteObjectUser *)targetUser {
    self = [super init];
    if (self) {
        _pfObjects = pfObjects;
        _state = kRJDataMarshallerOperationStateNotStarted;
        _pfRelation = relation;
        _targetCategory = targetCategory;
        _targetUser = targetUser;
    }
    return self;
}

@end
