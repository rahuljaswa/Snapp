//
//  RJDataMarshaller.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJDataMarshaller.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectMessage.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectThread.h"
#import "RJManagedObjectUser.h"
#import "RJRemoteObjectCategory.h"
#import "RJRemoteObjectComment.h"
#import "RJRemoteObjectFlag.h"
#import "RJRemoteObjectLike.h"
#import "RJRemoteObjectMessage.h"
#import "RJRemoteObjectPost.h"
#import "RJRemoteObjectThread.h"
#import "RJRemoteObjectUser.h"

@implementation RJDataMarshaller

#pragma mark - Private Class Methods

+ (NSArray *)updateOrCreateImageObjectsWithRemoteImageObjects:(NSArray *)remoteImageObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Image";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (id remoteImage in remoteImageObjects) {
            __block NSString *remoteImageURL = nil;
            NSUInteger indexOfLocalImage = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectImage *localImage = obj;
                if ([remoteImage isKindOfClass:[NSString class]]) {
                    NSString *remoteImageString = remoteImage;
                    remoteImageURL = remoteImageString;
                } else if ([remoteImage isKindOfClass:[PFFile class]]) {
                    PFFile *remoteImageFile = remoteImage;
                    remoteImageURL = remoteImageFile.url;
                }
                
                return [remoteImageURL isEqualToString:localImage.imageURL];
            }];
            
            RJManagedObjectImage *localImage = nil;
            if (indexOfLocalImage == NSNotFound) {
                localImage = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                localImage.createdAt = [NSDate date];
            } else {
                localImage = fetchedObjects[indexOfLocalImage];
            }
            localImage.imageURL = remoteImageURL;
            
            [objects addObject:localImage];
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateMessageObjectsWithRJMessageObjects:(NSArray *)rjMessageObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Message";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectMessage *remoteMessage in rjMessageObjects) {
            NSUInteger indexOfLocalMessage = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectMessage *localMessage = obj;
                return [remoteMessage.objectId isEqualToString:localMessage.objectId];
            }];
            
            if (remoteMessage.deleted && (indexOfLocalMessage != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalMessage]];
            } else {
                RJManagedObjectMessage *localMessage = nil;
                if (indexOfLocalMessage == NSNotFound) {
                    localMessage = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localMessage = fetchedObjects[indexOfLocalMessage];
                }
                localMessage.createdAt = remoteMessage.createdAt;
                localMessage.text = remoteMessage.text;
                localMessage.objectId = remoteMessage.objectId;
                
                if (remoteMessage.readReceipts) {
                    NSArray *readReceipts = [self updateOrCreateUserObjectsWithRJUserObjects:remoteMessage.readReceipts context:context];
                    localMessage.readReceipts = [NSSet setWithArray:readReceipts];
                }
                
                if (remoteMessage.sender) {
                    NSArray *senders = [self updateOrCreateUserObjectsWithRJUserObjects:@[remoteMessage.sender] context:context];
                    localMessage.sender = [senders firstObject];
                }
                
                if (remoteMessage.thread) {
                    NSArray *threads = [self updateOrCreateThreadObjectsWithRJThreadObjects:@[remoteMessage.thread] context:context];
                    localMessage.thread = [threads firstObject];
                }
                
                [objects addObject:localMessage];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateThreadObjectsWithRJThreadObjects:(NSArray *)rjThreadObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Thread";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectThread *remoteThread in rjThreadObjects) {
            NSUInteger indexOfLocalThread = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJRemoteObjectThread *localThread = obj;
                return [remoteThread.objectId isEqualToString:localThread.objectId];
            }];
            
            if (remoteThread.deleted && (indexOfLocalThread != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalThread]];
            } else {
                RJManagedObjectThread *localThread = nil;
                if (indexOfLocalThread == NSNotFound) {
                    localThread = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localThread = fetchedObjects[indexOfLocalThread];
                }
                localThread.createdAt = remoteThread.createdAt;
                localThread.updatedAt = remoteThread.updatedAt;
                localThread.objectId = remoteThread.objectId;
                
                if (remoteThread.readReceipts) {
                    NSArray *readReceipts = [self updateOrCreateUserObjectsWithRJUserObjects:remoteThread.readReceipts context:context];
                    localThread.readReceipts = [NSSet setWithArray:readReceipts];
                }
                
                if (remoteThread.contacter) {
                    NSArray *contacters = [self updateOrCreateUserObjectsWithRJUserObjects:@[remoteThread.contacter] context:context];
                    localThread.contacter = [contacters firstObject];
                }
                
                if (remoteThread.post) {
                    NSArray *posts = [self updateOrCreatePostObjectsWithRJPostObjects:@[remoteThread.post] context:context];
                    localThread.post = [posts firstObject];
                }
                
                [objects addObject:localThread];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreatePostObjectsWithRJPostObjects:(NSArray *)rjPostObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Post";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectPost *remotePost in rjPostObjects) {
            NSUInteger indexOfLocalPost = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectPost *localPost = obj;
                return [remotePost.objectId isEqualToString:localPost.objectId];
            }];
            
            if (remotePost.deleted && (indexOfLocalPost != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalPost]];
            } else {
                RJManagedObjectPost *localPost = nil;
                if (indexOfLocalPost == NSNotFound) {
                    localPost = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localPost = fetchedObjects[indexOfLocalPost];
                }
                localPost.createdAt = remotePost.createdAt;
                localPost.forSale = [NSNumber numberWithBool:remotePost.forSale];
                localPost.name = remotePost.name;
                localPost.objectId = remotePost.objectId;
                localPost.longDescription = remotePost.longDescription;
                
                if (remotePost.location) {
                    localPost.longitude = @(remotePost.location.longitude);
                    localPost.latitude = @(remotePost.location.latitude);
                }
                
                if (remotePost.locationDescription) {
                    localPost.locationDescription = remotePost.locationDescription;
                }
                
                if (remotePost.creator) {
                    NSArray *creators = [self updateOrCreateUserObjectsWithRJUserObjects:@[remotePost.creator] context:context];
                    localPost.creator = [creators firstObject];
                }
                
                if (remotePost.categories) {
                    NSArray *categories = [self updateOrCreateCategoryObjectsWithRJCategoryObjects:remotePost.categories context:context];
                    localPost.categories = [NSSet setWithArray:categories];
                }
                
                if (remotePost.images) {
                    NSArray *images = [self updateOrCreateImageObjectsWithRemoteImageObjects:remotePost.images context:context];
                    localPost.images = [NSSet setWithArray:images];
                }
                
                if (remotePost.likes) {
                    NSArray *likes = [self updateOrCreateLikeObjectsWithRJLikeObjects:remotePost.likes context:context];
                    localPost.likes = [NSSet setWithArray:likes];
                }
                
                if (remotePost.comments) {
                    NSArray *comments = [self updateOrCreateCommentObjectsWithRJCommentObjects:remotePost.comments context:context];
                    localPost.comments = [NSSet setWithArray:comments];
                }
                
                [objects addObject:localPost];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateLikeObjectsWithRJLikeObjects:(NSArray *)rjLikeObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Like";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectLike *remoteLike in rjLikeObjects) {
            NSUInteger indexOfLocalLike = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectLike *localLike = obj;
                return [remoteLike.objectId isEqualToString:localLike.objectId];
            }];
            
            if (remoteLike.deleted && (indexOfLocalLike != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalLike]];
            } else {
                RJManagedObjectLike *localLike = nil;
                if (indexOfLocalLike == NSNotFound) {
                    localLike = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localLike = fetchedObjects[indexOfLocalLike];
                }
                localLike.createdAt = remoteLike.createdAt;
                localLike.objectId = remoteLike.objectId;
                
                if (remoteLike.creator) {
                    NSArray *creators = [self updateOrCreateUserObjectsWithRJUserObjects:@[remoteLike.creator] context:context];
                    localLike.creator = [creators firstObject];
                }
                
                [objects addObject:localLike];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateFlagObjectsWithRJFlagObjects:(NSArray *)rjFlagObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Flag";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectFlag *remoteFlag in rjFlagObjects) {
            NSUInteger indexOfLocalFlag = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectFlag *localFlag = obj;
                return [remoteFlag.objectId isEqualToString:localFlag.objectId];
            }];
            
            if (remoteFlag.deleted && (indexOfLocalFlag != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalFlag]];
            } else {
                RJManagedObjectFlag *localFlag = nil;
                if (indexOfLocalFlag == NSNotFound) {
                    localFlag = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localFlag = fetchedObjects[indexOfLocalFlag];
                }
                localFlag.createdAt = remoteFlag.createdAt;
                localFlag.reason = @(remoteFlag.reason);
                localFlag.objectId = remoteFlag.objectId;
                
                if (remoteFlag.creator) {
                    NSArray *creators = [self updateOrCreateUserObjectsWithRJUserObjects:@[remoteFlag.creator] context:context];
                    localFlag.creator = [creators firstObject];
                }
                
                if (remoteFlag.post) {
                    NSArray *posts = [self updateOrCreatePostObjectsWithRJPostObjects:@[remoteFlag.post] context:context];
                    localFlag.post = [posts firstObject];
                }
                
                [objects addObject:localFlag];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateCommentObjectsWithRJCommentObjects:(NSArray *)rjCommentObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"Comment";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectComment *remoteComment in rjCommentObjects) {
            NSUInteger indexOfLocalComment = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectComment *localComment = obj;
                return [remoteComment.objectId isEqualToString:localComment.objectId];
            }];
            
            if (remoteComment.deleted && (indexOfLocalComment != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalComment]];
            } else {
                RJManagedObjectComment *localComment = nil;
                if (indexOfLocalComment == NSNotFound) {
                    localComment = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localComment = fetchedObjects[indexOfLocalComment];
                }
                localComment.createdAt = remoteComment.createdAt;
                localComment.text = remoteComment.text;
                localComment.objectId = remoteComment.objectId;
                
                if (remoteComment.creator) {
                    NSArray *creators = [self updateOrCreateUserObjectsWithRJUserObjects:@[remoteComment.creator] context:context];
                    localComment.creator = [creators firstObject];
                }
                
                [objects addObject:localComment];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateCategoryObjectsWithRJCategoryObjects:(NSArray *)rjCategoryObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"PostCategory";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (RJRemoteObjectCategory *remoteCategory in rjCategoryObjects) {
            NSUInteger indexOfLocalCategory = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectPostCategory *localCategory = obj;
                return [remoteCategory.objectId isEqualToString:localCategory.objectId];
            }];
            
            if (remoteCategory.deleted && (indexOfLocalCategory != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalCategory]];
            } else {
                RJManagedObjectPostCategory *localCategory = nil;
                if (indexOfLocalCategory == NSNotFound) {
                    localCategory = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localCategory = fetchedObjects[indexOfLocalCategory];
                }
                localCategory.createdAt = remoteCategory.createdAt;
                localCategory.name = remoteCategory.name;
                localCategory.objectId = remoteCategory.objectId;
                
                if (remoteCategory.image) {
                    NSArray *images = [self updateOrCreateImageObjectsWithRemoteImageObjects:@[remoteCategory.image] context:context];
                    localCategory.image = [images firstObject];
                }
                
                [objects addObject:localCategory];
            }
        }
    }
    
    return objects;
}

+ (NSArray *)updateOrCreateUserObjectsWithRJUserObjects:(NSArray *)rjUserObjects context:(NSManagedObjectContext *)context {
    NSString *entityName = @"User";
    NSError *error = nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
        for (RJRemoteObjectUser *remoteUser in rjUserObjects) {
            
            NSUInteger indexOfLocalUser = [fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectUser *localUser = obj;
                return [remoteUser.objectId isEqualToString:localUser.objectId];
            }];
            
            if (remoteUser.deleted && (indexOfLocalUser != NSNotFound)) {
                [context deleteObject:fetchedObjects[indexOfLocalUser]];
            } else {
                RJManagedObjectUser *localUser = nil;
                if (indexOfLocalUser == NSNotFound) {
                    localUser = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                } else {
                    localUser = fetchedObjects[indexOfLocalUser];
                }
                localUser.createdAt = remoteUser.createdAt;
                localUser.name = remoteUser.name;
                localUser.objectId = remoteUser.objectId;
                localUser.currentUser = @([currentUser.objectId isEqualToString:localUser.objectId]);
                localUser.skeleton = @(remoteUser.skeleton);
                
                if (remoteUser.image) {
                    NSArray *images = [self updateOrCreateImageObjectsWithRemoteImageObjects:@[remoteUser.image] context:context];
                    localUser.image = [images firstObject];
                }
                
                [objects addObject:localUser];
            }
        }
    }
    return objects;
}

#pragma mark - Private Class Methods - Completion

+ (void)executeCompletionBlock:(void (^)(void))completionBlock onMainQueueAfterContextAndParentContextSave:(NSManagedObjectContext *)context {
    if ([context hasChanges]) {
        NSError *error = nil;
        BOOL saved = [context save:&error];
        if (!saved) {
            NSLog(@"Error saving to thread context\n\n%@", [error localizedDescription]);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *parentContext = [context parentContext];
        if ([parentContext hasChanges]) {
            NSError *error = nil;
            BOOL saved = [parentContext save:&error];
            if (!saved) {
                NSLog(@"Error saving to master context\n\n%@", [error localizedDescription]);
            }
        }
        
        if (completionBlock) {
            completionBlock();
        }
    });
}

#pragma mark - Public Class Methods

+ (void)updateOrCreateObjectsWithPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetCategory:(RJRemoteObjectCategory *)targetCategory targetUser:(RJRemoteObjectUser *)targetUser completion:(void (^)(void))completion {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [threadContext setParentContext:context];
        
        RJManagedObjectUser *localTargetUser = nil;
        if (targetUser) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"objectId == %@", targetUser.objectId];
            NSError *error = nil;
            localTargetUser = [[threadContext executeFetchRequest:fetchRequest error:&error] firstObject];
            if (error) {
                NSLog(@"Error fetching localTargetUser\n\n%@", [error localizedDescription]);
            }
        }
        
        RJManagedObjectPostCategory *localTargetCategory = nil;
        if (targetCategory) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PostCategory"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"objectId == %@", targetCategory.objectId];
            NSError *error = nil;
            localTargetCategory = [[threadContext executeFetchRequest:fetchRequest error:&error] firstObject];
            if (error) {
                NSLog(@"Error fetching localTargetCategory\n\n%@", [error localizedDescription]);
            }
        }
        
        switch (relation) {
            case kRJDataMarshallerPFRelationNone: {
                PFObject *representativeObject = [pfObjects firstObject];
                
                [threadContext performBlock:^{
                    if ([representativeObject isMemberOfClass:[RJRemoteObjectCategory class]]) {
                        [self updateOrCreateCategoryObjectsWithRJCategoryObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectUser class]]) {
                        [self updateOrCreateUserObjectsWithRJUserObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectComment class]]) {
                        [self updateOrCreateCommentObjectsWithRJCommentObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectPost class]]) {
                        [self updateOrCreatePostObjectsWithRJPostObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectLike class]]) {
                        [self updateOrCreateLikeObjectsWithRJLikeObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectFlag class]]) {
                        [self updateOrCreateFlagObjectsWithRJFlagObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectThread class]]) {
                        [self updateOrCreateThreadObjectsWithRJThreadObjects:pfObjects context:threadContext];
                    } else if ([representativeObject isMemberOfClass:[RJRemoteObjectMessage class]]) {
                        [self updateOrCreateMessageObjectsWithRJMessageObjects:pfObjects context:threadContext];
                    }
                    [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                }];
                break;
            }
            case kRJDataMarshallerPFRelationCategoryFollowingUsers: {
                if (!localTargetCategory) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Target category cannot be nil for kRJDataMarshallerPFRelationCategoryFollowingUsers" userInfo:nil];
                }
                if (([pfObjects count] > 0) && ![[[pfObjects firstObject] parseClassName] isEqualToString:[[RJRemoteObjectUser class] parseClassName]]) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Relationship objects for kRJDataMarshallerPFRelationCategoryFollowingUsers must belong to RJRemoteObjectUser class" userInfo:nil];
                }
               
                NSArray *relationUsers = [self updateOrCreateUserObjectsWithRJUserObjects:pfObjects context:threadContext];
                [localTargetCategory addFollowers:[NSSet setWithArray:relationUsers]];
                [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                break;
            }
            case kRJDataMarshallerPFRelationUserBlockedUsers: {
                if (!localTargetUser) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Target user cannot be nil for kRJDataMarshallerPFRelationUserBlockedUsers" userInfo:nil];
                }
                if (([pfObjects count] > 0) && ![[[pfObjects firstObject] parseClassName] isEqualToString:[[RJRemoteObjectUser class] parseClassName]]) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Relationship objects for kRJDataMarshallerPFRelationUserBlockedUsers must belong to RJRemoteObjectUser class" userInfo:nil];
                }
                
                NSArray *relationUsers = [self updateOrCreateUserObjectsWithRJUserObjects:pfObjects context:threadContext];
                [localTargetUser addBlockedUsers:[NSSet setWithArray:relationUsers]];
                [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                break;
            }
            case kRJDataMarshallerPFRelationUserFollowers: {
                if (!localTargetUser) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Target user cannot be nil for kRJDataMarshallerPFRelationUserFollowers" userInfo:nil];
                }
                if (([pfObjects count] > 0) && ![[[pfObjects firstObject] parseClassName] isEqualToString:[[RJRemoteObjectUser class] parseClassName]]) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Relationship objects for kRJDataMarshallerPFRelationUserFollowers must belong to RJRemoteObjectUser class" userInfo:nil];
                }
                
                NSArray *relationUsers = [self updateOrCreateUserObjectsWithRJUserObjects:pfObjects context:threadContext];
                [localTargetUser addFollowers:[NSSet setWithArray:relationUsers]];
                [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                break;
            }
            case kRJDataMarshallerPFRelationUserFollowingCategories: {
                if (!localTargetUser) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Target user cannot be nil for kRJDataMarshallerPFRelationUserFollowingCategories" userInfo:nil];
                }
                if (([pfObjects count] > 0) && ![[[pfObjects firstObject] parseClassName] isEqualToString:[[RJRemoteObjectCategory class] parseClassName]]) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Relationship objects for kRJDataMarshallerPFRelationUserFollowingCategories must belong to RJRemoteObjectCategory class" userInfo:nil];
                }
                
                NSArray *relationCategories = [self updateOrCreateCategoryObjectsWithRJCategoryObjects:pfObjects context:threadContext];
                [localTargetUser addFollowingCategories:[NSSet setWithArray:relationCategories]];
                [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                break;
            }
            case kRJDataMarshallerPFRelationUserFollowingUsers: {
                if (!localTargetUser) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Target user cannot be nil for kRJDataMarshallerPFRelationUserFollowingUsers" userInfo:nil];
                }
                if (([pfObjects count] > 0) && ![[[pfObjects firstObject] parseClassName] isEqualToString:[[RJRemoteObjectUser class] parseClassName]]) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Relationship objects for kRJDataMarshallerPFRelationUserFollowingUsers must belong to RJRemoteObjectUser class" userInfo:nil];
                }
                
                NSArray *relationUsers = [self updateOrCreateUserObjectsWithRJUserObjects:pfObjects context:threadContext];
                [localTargetUser addFollowingUsers:[NSSet setWithArray:relationUsers]];
                [self executeCompletionBlock:completion onMainQueueAfterContextAndParentContextSave:threadContext];
                break;
            }
        }
    });
}

@end
