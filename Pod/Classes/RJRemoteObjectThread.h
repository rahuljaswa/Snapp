//
//  RJRemoteObjectThread.h
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import <Parse/Parse.h>


@class RJRemoteObjectMessage;
@class RJRemoteObjectPost;
@class RJRemoteObjectUser;

@interface RJRemoteObjectThread : PFObject <PFSubclassing>

@property (nonatomic, strong) RJRemoteObjectUser *contacter;
@property (nonatomic, assign, readonly) BOOL deleted;
@property (nonatomic, strong) RJRemoteObjectMessage *lastMessage;
@property (nonatomic, strong, readonly) PFRelation *messages;
@property (nonatomic, strong) RJRemoteObjectPost *post;
@property (nonatomic, strong) NSArray *readReceipts;

@end
