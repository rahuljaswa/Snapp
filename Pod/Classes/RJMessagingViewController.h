//
//  RJMessagingViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import "RJViewControllerDataSourceProtocol.h"
#import <ChatViewControllers/RJChatTableViewController.h>


@class RJManagedObjectThread;

@interface RJMessagingViewController : RJChatTableViewController <RJViewControllerDataSourceProtocol>

- (instancetype)initWithThread:(RJManagedObjectThread *)thread;

@end
