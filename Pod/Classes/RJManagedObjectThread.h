//
//  RJManagedObjectThread.h
//  NINEXX
//
//  Created by Rahul Jaswa on 2/28/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class RJManagedObjectMessage;
@class RJManagedObjectPost;
@class RJManagedObjectUser;

@interface RJManagedObjectThread : NSManagedObject

@property (nonatomic, retain) RJManagedObjectUser *contacter;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) RJManagedObjectMessage *lastMessage;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) RJManagedObjectPost *post;
@property (nonatomic, retain) NSSet *readReceipts;
@property (nonatomic, retain) NSDate *updatedAt;

@end


@interface RJManagedObjectThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(RJManagedObjectMessage *)value;
- (void)removeMessagesObject:(RJManagedObjectMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addReadReceiptsObject:(RJManagedObjectUser *)value;
- (void)removeReadReceiptsObject:(RJManagedObjectUser *)value;
- (void)addReadReceipts:(NSSet *)values;
- (void)removeReadReceipts:(NSSet *)values;

@end
