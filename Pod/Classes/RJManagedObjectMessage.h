//
//  RJManagedObjectMessage.h
//  NINEXX
//
//  Created by Rahul Jaswa on 2/28/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class RJManagedObjectThread;
@class RJManagedObjectUser;

@interface RJManagedObjectMessage : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) RJManagedObjectThread *thread;
@property (nonatomic, retain) RJManagedObjectThread *threadWhereLastMessage;
@property (nonatomic, retain) NSSet *readReceipts;
@property (nonatomic, retain) RJManagedObjectUser *sender;

@end


@interface RJManagedObjectMessage (CoreDataGeneratedAccessors)

- (void)addReadReceiptsObject:(RJManagedObjectUser *)value;
- (void)removeReadReceiptsObject:(RJManagedObjectUser *)value;
- (void)addReadReceipts:(NSSet *)values;
- (void)removeReadReceipts:(NSSet *)values;

@end
