//
//  RJRemoteObjectMessage.h
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import <Parse/Parse.h>


@class RJRemoteObjectUser;
@class RJRemoteObjectThread;

@interface RJRemoteObjectMessage : PFObject <PFSubclassing>

@property (nonatomic, assign, readonly) BOOL deleted;
@property (nonatomic, strong) NSArray *readReceipts;
@property (nonatomic, strong) RJRemoteObjectUser *sender;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) RJRemoteObjectThread *thread;

@end
