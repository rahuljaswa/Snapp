//
//  RJParseUtils.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJManagedObjectComment.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectMessage.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectThread.h"
#import "RJManagedObjectUser.h"
#import "RJParseUtils.h"
#import "RJRemoteObjectCategory.h"
#import "RJRemoteObjectComment.h"
#import "RJRemoteObjectFlag.h"
#import "RJRemoteObjectLike.h"
#import "RJRemoteObjectMessage.h"
#import "RJRemoteObjectPost.h"
#import "RJRemoteObjectThread.h"
#import "RJRemoteObjectUser.h"
#import "RJStore.h"


@interface RJParseUtils ()

@end


@implementation RJParseUtils

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static RJParseUtils *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Private Instance Methods

- (NSSet *)createLocalImagesFromImages:(NSArray *)images {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    
    NSMutableSet *localImages = [[NSMutableSet alloc] init];
    for (id image in images) {
        RJManagedObjectImage *localImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
        localImage.createdAt = [NSDate date];
        if ([image isKindOfClass:[NSString class]]) {
            NSString *imageURL = image;
            localImage.imageURL = imageURL;
        } else if ([image isKindOfClass:[PFFile class]]) {
            PFFile *file = image;
            localImage.imageURL = file.url;
        }
        [localImages addObject:localImage];
    }
    return localImages;
}

- (void)createNewLocalCategoriesForRemoteCategories:(NSArray *)remoteCategories completion:(void (^)(NSArray *localCategories))completion {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSMutableArray *mutableLocalCategories = [[NSMutableArray alloc] init];
    for (RJRemoteObjectCategory *remoteCategory in remoteCategories) {
        RJManagedObjectPostCategory *localCategory = [NSEntityDescription insertNewObjectForEntityForName:@"PostCategory" inManagedObjectContext:context];
        localCategory.name = remoteCategory.name;
        localCategory.objectId = remoteCategory.objectId;
        [mutableLocalCategories addObject:localCategory];
    }
    NSError *error = nil;
    if ([context save:&error]) {
        completion(mutableLocalCategories);
    } else if (completion) {
        NSLog(@"Error creating new categories\n\n%@", [error localizedDescription]);
        completion(nil);
    }
}

- (void)createNewRemoteCategoriesForCategories:(NSArray *)categories completion:(void (^)(NSArray *remoteCategories))completion {
    NSMutableArray *mutableRemoteCategories = [[NSMutableArray alloc] init];
    for (NSString *category in categories) {
        RJRemoteObjectCategory *remoteCategory = [RJRemoteObjectCategory object];
        remoteCategory.appIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        remoteCategory.name = category;
        [mutableRemoteCategories addObject:remoteCategory];
    }
    [PFObject saveAllInBackground:mutableRemoteCategories block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (completion) {
                completion(mutableRemoteCategories);
            }
        } else {
            NSLog(@"Error saving new remote categories\n\n%@", [error localizedDescription]);
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject completion:(void (^)(BOOL succeeded))completion {
    [[managedObject managedObjectContext] deleteObject:managedObject];
    NSError *error = nil;
    if ([[managedObject managedObjectContext] save:&error]) {
        if (completion) {
            completion(YES);
        }
    } else {
        NSLog(@"Error deleting managed object\n\n%@", [error localizedDescription]);
        if (completion) {
            completion(NO);
        }
    }
}

- (NSArray *)remoteCategories:(NSArray *)remoteCategories matchingLocalCategories:(NSArray *)localCategories {
    NSIndexSet *matchingRemoteCategories = [remoteCategories indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RJRemoteObjectCategory *remoteCategory = obj;
        for (RJManagedObjectPostCategory *localCategory in localCategories) {
            if ([localCategory.objectId isEqualToString:remoteCategory.objectId]) {
                return YES;
            }
        }
        return NO;
    }];
    return [remoteCategories objectsAtIndexes:matchingRemoteCategories];
}

- (void)fetchPostWithObjectId:(NSString *)objectId completion:(void (^)(RJRemoteObjectPost *post))completion {
    PFQuery *postQuery = [RJRemoteObjectPost query];
    [postQuery includeKey:@"images"];
    [postQuery getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            if (completion) {
                completion(nil);
            }
        } else {
            if (completion) {
                RJRemoteObjectPost *post = (RJRemoteObjectPost *)object;
                completion(post);
            }
        }
    }];
}

- (void)fetchRemoteCategoriesWithCompletion:(void (^)(NSArray *objects))completion {
    PFQuery *categoryQuery = [RJRemoteObjectCategory query];
    categoryQuery.limit = 1000;
    [categoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && completion) {
            completion(objects);
        } else {
            NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FIND CATEGORIES\n%@", [error localizedDescription]);
            completion(nil);
        }
    }];
}

- (void)prepareImages:(NSArray *)images remotePost:(RJRemoteObjectPost *)remotePost forSaveWithCompletion:(void (^)(NSArray *images))completion {
    NSMutableArray *imagesToSaveToRemotePost = [[NSMutableArray alloc] init];
    NSMutableArray *filesToSaveBeforeSavingToRemotePost = [[NSMutableArray alloc] init];
    
    if (remotePost) {
        for (id localImage in images) {
            BOOL isNewImage = YES;
            
            if ([localImage isKindOfClass:[RJManagedObjectImage class]]) {
                RJManagedObjectImage *localManagedObjectImage = localImage;
                for (id remoteImage in remotePost.images) {
                    NSString *remoteImageURL = nil;
                    if ([remoteImage isKindOfClass:[PFFile class]]) {
                        PFFile *remoteImageFile = remoteImage;
                        remoteImageURL = remoteImageFile.url;
                    } else if ([remoteImage isKindOfClass:[NSString class]]) {
                        remoteImageURL = remoteImage;
                    }
                    
                    if ([localManagedObjectImage.imageURL isEqualToString:remoteImageURL]) {
                        [imagesToSaveToRemotePost addObject:remoteImage];
                        isNewImage = NO;
                        break;
                    }
                }
            }
            
            if (isNewImage) {
                if ([localImage isKindOfClass:[NSString class]]) {
                    [imagesToSaveToRemotePost addObject:localImage];
                } else if ([localImage isKindOfClass:[UIImage class]]) {
                    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(localImage, 0.5f)];
                    [filesToSaveBeforeSavingToRemotePost addObject:file];
                    [imagesToSaveToRemotePost addObject:file];
                }
            }
        }
    } else {
        for (id image in images) {
            if ([image isKindOfClass:[NSString class]]) {
                [imagesToSaveToRemotePost addObject:image];
            } else if ([image isKindOfClass:[UIImage class]]) {
                PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.5f)];
                [filesToSaveBeforeSavingToRemotePost addObject:file];
                [imagesToSaveToRemotePost addObject:file];
            }
        }
    }
    
    if ([filesToSaveBeforeSavingToRemotePost count] > 0) {
        [PFObject saveAllInBackground:filesToSaveBeforeSavingToRemotePost block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (completion) {
                    completion(imagesToSaveToRemotePost);
                }
            } else {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO SAVE IMAGE FILES\n%@", [error localizedDescription]);
                if (completion) {
                    completion(nil);
                }
            }
        }];
    } else {
        if (completion) {
            completion(imagesToSaveToRemotePost);
        }
    }
}

- (void)saveLocalPost:(RJManagedObjectPost *)localPost completion:(void (^)(BOOL success))completion {
    NSError *error = nil;
    if ([[localPost managedObjectContext] save:&error]) {
        if (completion) {
            completion(YES);
        }
    } else {
        NSLog(@"Error saving new Post object to persistent store\n\n%@", [error localizedDescription]);
        if (completion) {
            completion(NO);
        }
    }
}

- (void)updateLocalPost:(RJManagedObjectPost *)localPost withName:(NSString *)name creator:(RJManagedObjectUser *)creator longDescription:(NSString *)longDescription localCategories:(NSArray *)localCategories forSale:(BOOL)forSale location:(CLLocation *)location locationDescription:(NSString *)locationDescription completion:(void (^)(void))completion {
    localPost.creator = creator;
    localPost.forSale = [NSNumber numberWithBool:forSale];
    localPost.name = name;
    localPost.latitude = @(location.coordinate.latitude);
    localPost.longitude = @(location.coordinate.longitude);
    localPost.longDescription = longDescription;
    localPost.locationDescription = locationDescription;
    localPost.categories = [NSSet setWithArray:localCategories];
    if (completion) {
        completion();
    }
}

- (void)updateLocalPost:(RJManagedObjectPost *)localPost withRemoteObjectId:(NSString *)remoteObjectId completion:(void (^)(BOOL succeeded))completion {
    localPost.objectId = remoteObjectId;
    NSError *error = nil;
    if ([[localPost managedObjectContext] save:&error]) {
        if (completion) {
            completion(YES);
        }
    } else {
        NSLog(@"Error saving objectId to Post object in persistent store\n\n%@", [error localizedDescription]);
        if (completion) {
            completion(NO);
        }
    }
}

- (void)updateLocalPost:(RJManagedObjectPost *)localPost withImages:(NSArray *)images completion:(void (^)(BOOL succeeded))completion {
    localPost.images = [self createLocalImagesFromImages:images];
    NSError *error = nil;
    if ([[localPost managedObjectContext] save:&error]) {
        if (completion) {
            completion(YES);
        }
    } else {
        NSLog(@"Error saving images to Post object in persistent store\n\n%@", [error localizedDescription]);
        if (completion) {
            completion(NO);
        }
    }
}

- (void)updateRemotePost:(RJRemoteObjectPost *)remotePost withName:(NSString *)name longDescription:(NSString *)longDescription forSale:(BOOL)forSale remoteCategories:(NSArray *)remoteCategories localCategories:(NSArray *)localCategories location:(CLLocation *)location locationDescription:(NSString *)locationDescription localCreator:(RJManagedObjectUser *)localCreator completion:(void (^)(BOOL success))completion {
    remotePost.name = name;
    remotePost.location = [PFGeoPoint geoPointWithLocation:location];
    remotePost.locationDescription = locationDescription;
    remotePost.longDescription = longDescription;
    remotePost.forSale = forSale;
    remotePost.categories = [self remoteCategories:remoteCategories matchingLocalCategories:localCategories];
    
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:localCreator.objectId block:^(PFObject *object, NSError *error) {
        if (object) {
            remotePost.creator = (RJRemoteObjectUser *)object;
            if (completion) {
                completion(YES);
            }
        } else {
            NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH USER\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        }
    }];
}

- (void)updateRemotePost:(RJRemoteObjectPost *)remotePost withImages:(NSArray *)images completion:(void (^)(BOOL succeeded))completion {
    remotePost.images = images;
    [remotePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED POST");
            if (completion) {
                completion(YES);
            }
        } else {
            NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE POST\n%@", [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - Public Instance Methods

- (void)updateUser:(RJManagedObjectUser *)user withImage:(UIImage *)image remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localUser = user;
    [[RJRemoteObjectUser query] getObjectInBackgroundWithId:localUser.objectId block:^(PFObject *object, NSError *error) {
        if (error || !object) {
            if (remoteSuccess) {
                remoteSuccess(NO);
            }
        } else {
            RJRemoteObjectUser *remoteUser = (RJRemoteObjectUser *)object;
            PFFile *imageFile = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.5f)];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    remoteUser.image = imageFile;
                    [remoteUser saveEventually:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE USER IMAGE\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        } else {
                            NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED USER IMAGE");
                            
                            if (remoteUser.image) {
                                NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
                                RJManagedObjectImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image"
                                                                                            inManagedObjectContext:context];
                                image.imageURL = remoteUser.image.url;
                                [image addUsersObject:localUser];
                                
                                NSError *error = nil;
                                if (![context save:&error]) {
                                    NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
                                }
                                
                                if (remoteSuccess) {
                                    remoteSuccess(YES);
                                }
                            } else {
                                if (remoteSuccess) {
                                    remoteSuccess(YES);
                                }
                            }
                        }
                    }];
                } else {
                    if (remoteSuccess) {
                        remoteSuccess(NO);
                    }
                }
            }];
        }
    }];
}

- (void)markThreadAsRead:(RJManagedObjectThread *)thread remoteSuccess:(void (^)(BOOL))remoteSuccess {
    NSManagedObjectContext *context = [thread managedObjectContext];
    
    RJManagedObjectUser *currentUser = [RJManagedObjectUser currentUser];
    [thread addReadReceiptsObject:currentUser];
    for (RJManagedObjectMessage *message in thread.messages) {
        [message addReadReceiptsObject:currentUser];
    }
    
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectThread query] getObjectInBackgroundWithId:thread.objectId block:^(PFObject *fetchedObject, NSError *error) {
            if (fetchedObject) {
                RJRemoteObjectThread *remoteThread = (RJRemoteObjectThread *)fetchedObject;
                [remoteThread addUniqueObject:[RJRemoteObjectUser currentUser] forKey:@"readReceipts"];
                [remoteThread saveEventually:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE THREAD READ RECEIPTS\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED THREAD READ RECEIPTS");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    }
                }];
            } else {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH THREAD");
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            }
        }];
    } else {
        NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
    }
}

- (void)createNewUserWithName:(NSString *)name image:(UIImage *)image remoteSuccess:(void (^)(BOOL))remoteSuccess {
    PFUser *currentUser = [PFUser currentUser];
    __block NSString *currentUserName = currentUser.username;
    
    RJRemoteObjectUser *user = (RJRemoteObjectUser *)[RJRemoteObjectUser user];
    user.name = name;
    user.username = name;
    user.password = name;
    user.skeleton = YES;
    
    PFFile *imageFile = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.5f)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            user.image = imageFile;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE USER IMAGE\n%@", [error localizedDescription]);
                    if (remoteSuccess) {
                        remoteSuccess(NO);
                    }
                } else {
                    NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED USER IMAGE");
                    
                    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                        [PFUser logInWithUsernameInBackground:currentUserName password:currentUserName block:^(PFUser *loggedInUser, NSError *error) {
                            [RJDataMarshaller updateOrCreateObjectsWithPFObjects:@[user] relation:kRJDataMarshallerPFRelationNone targetCategory:nil targetUser:nil completion:^{
                                NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
                                NSError *error = nil;
                                
                                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
                                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"objectId == %@", user.objectId];
                                RJManagedObjectUser *localUser = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
                                
                                if (error) {
                                    NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
                                    if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                } else {
                                    RJManagedObjectImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
                                    image.imageURL = user.image.url;
                                    localUser.image = image;
                                    
                                    if ([context save:&error]) {
                                        if (remoteSuccess) {
                                            remoteSuccess(YES);
                                        }
                                    } else {
                                        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
                                        if (remoteSuccess) {
                                            remoteSuccess(NO);
                                        }
                                    }
                                }
                            }];
                        }];
                    }];
                }
            }];
        } else {
            if (remoteSuccess) {
                remoteSuccess(NO);
            }
        }
    }];
}

- (void)createNewThreadForPost:(RJManagedObjectPost *)post initialMessage:(NSString *)initialMessage remoteSuccess:(void (^)(BOOL))remoteSuccess {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    
    RJManagedObjectThread *localThread = [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:context];
    localThread.post = post;
    localThread.contacter = [RJManagedObjectUser currentUser];
    localThread.createdAt = [NSDate date];
    
    RJManagedObjectMessage *localMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    localMessage.createdAt = [NSDate date];
    localMessage.sender = [RJManagedObjectUser currentUser];
    localMessage.text = initialMessage;
    [localThread addMessagesObject:localMessage];
    
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:post.objectId block:^(PFObject *fetchedObject, NSError *error) {
            if (error || !fetchedObject) {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH POST");
                
                [context deleteObject:localMessage];
                [context deleteObject:localThread];
                
                if (![context save:&error]) {
                    NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                }
                
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectPost *remotePost = (RJRemoteObjectPost *)fetchedObject;
                
                RJRemoteObjectThread *remoteThread = [RJRemoteObjectThread object];
                remoteThread.post = remotePost;
                remoteThread.contacter = [RJRemoteObjectUser currentUser];
                
                RJRemoteObjectMessage *remoteMessage = [RJRemoteObjectMessage object];
                remoteMessage.text = initialMessage;
                remoteMessage.thread = remoteThread;
                remoteMessage.sender = [RJRemoteObjectUser currentUser];
                
                [PFObject saveAllInBackground:@[remoteThread, remoteMessage] block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        localMessage.objectId = remoteMessage.objectId;
                        localThread.objectId = remoteMessage.objectId;
                        
                        if ([context save:&error]) {
                            [remoteThread.messages addObject:remoteMessage];
                            [remoteThread saveEventually:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    if (remoteSuccess) {
                                        remoteSuccess(YES);
                                    }
                                } else {
                                    if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                }
                            }];
                        } else {
                            NSLog(@"Error updating objects\n\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE THREAD WITH MESSAGE\n%@", [error localizedDescription]);
                        
                        [context deleteObject:localMessage];
                        [context deleteObject:localThread];
                        
                        if (![context save:&error]) {
                            NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                        }
                        
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving new Comment object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)insertNewMessage:(NSString *)message inThread:(RJManagedObjectThread *)thread remoteSuccess:(void (^)(BOOL))remoteSuccess {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    
    RJManagedObjectMessage *localMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    localMessage.createdAt = [NSDate date];
    localMessage.sender = [RJManagedObjectUser currentUser];
    localMessage.text = message;
    [thread addMessagesObject:localMessage];
    
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectThread query] getObjectInBackgroundWithId:thread.objectId block:^(PFObject *fetchedObject, NSError *error) {
            if (error || !fetchedObject) {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH THREAD");
                
                [context deleteObject:localMessage];
                if (![context save:&error]) {
                    NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                }
                
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectThread *remoteThread = (RJRemoteObjectThread *)fetchedObject;
                
                RJRemoteObjectMessage *remoteMessage = [RJRemoteObjectMessage object];
                remoteMessage.sender = [RJRemoteObjectUser currentUser];
                remoteMessage.thread = (RJRemoteObjectThread *)remoteThread;
                remoteMessage.text = message;
                [remoteMessage saveEventually:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO CREATE MESSAGE\n%@", [error localizedDescription]);
                        
                        [context deleteObject:localMessage];
                        if (![context save:&error]) {
                            NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                        }
                        
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY CREATED MESSAGE");
                        localMessage.objectId = remoteMessage.objectId;
                        if ([context save:&error]) {
                            PFRelation *messages = [remoteThread messages];
                            [messages addObject:remoteMessage];
                            [remoteThread saveEventually:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE THREAD WITH MESSAGE\n%@", [error localizedDescription]);
                                    
                                    [context deleteObject:localMessage];
                                    if (![context save:&error]) {
                                        NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                                    }
                                    
                                    if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                } else {
                                    NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED POST WITH COMMENT");
                                    if (remoteSuccess) {
                                        remoteSuccess(YES);
                                    }
                                }
                            }];
                        } else {
                            NSLog(@"Error saving comment objectId to persistent store\n\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving new Comment object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)followCategory:(RJManagedObjectPostCategory *)category remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser addFollowingCategoriesObject:category];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectCategory query] getObjectInBackgroundWithId:category.objectId block:^(PFObject *object, NSError *error) {
            if (error || !object) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.followingCategories;
                [relation addObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY ADDED FOLLOWING CATEGORY");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO ADD FOLLOWING CATEGORY\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)unfollowCategory:(RJManagedObjectPostCategory *)category remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser removeFollowingCategoriesObject:category];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectCategory query] getObjectInBackgroundWithId:category.objectId block:^(PFObject *object, NSError *error) {
            if (error || !object) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.followingCategories;
                [relation removeObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY REMOVED FOLLOWING CATEGORY");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO REMOVE FOLLOWING CATEGORY\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)followUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser addFollowingUsersObject:user];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.followingUsers;
                [relation addObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY ADDED FOLLOWING USER");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO ADD FOLLOWING USER\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)unfollowUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser removeFollowingUsersObject:user];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.followingUsers;
                [relation removeObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY REMOVED FOLLOWING USER");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO REMOVE FOLLOWING USER\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)blockUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser addBlockedUsersObject:user];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    NSFetchRequest *postsToDeleteFetchRequest = [RJStore fetchRequestForAllPostsForCreator:user];
    NSArray *postsToDelete = [context executeFetchRequest:postsToDeleteFetchRequest error:&error];
    if (!postsToDelete) {
        NSLog(@"Error fetching postsToDelete\n\n%@", [error localizedDescription]);
    }
    
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc] init];
    for (RJManagedObjectPost *postToDelete in postsToDelete) {
        [objectsToDelete addObject:postToDelete];
        [objectsToDelete addObjectsFromArray:[postToDelete.likes allObjects]];
        [objectsToDelete addObjectsFromArray:[postToDelete.comments allObjects]];
        [objectsToDelete addObjectsFromArray:[postToDelete.images allObjects]];
    }
    
    for (NSManagedObject *objectToDelete in objectsToDelete) {
        [context deleteObject:objectToDelete];
    }
    
    if ([context save:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRJUserChangedBlockSettingsNotification object:[RJManagedObjectUser currentUser]];
        
        [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.blockedUsers;
                [relation addObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY ADDED BLOCKED USER");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO ADD BLOCKED USER\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)unblockUser:(RJManagedObjectUser *)user remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectUser *localCurrentUser = [RJManagedObjectUser currentUser];
    [localCurrentUser removeBlockedUsersObject:user];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRJUserChangedBlockSettingsNotification object:[RJManagedObjectUser currentUser]];
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    if ([context save:&error]) {
        [[RJRemoteObjectUser query] getObjectInBackgroundWithId:user.objectId block:^(PFObject *object, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
                PFRelation *relation = currentUser.blockedUsers;
                [relation removeObject:object];
                [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY REMOVED BLOCKED USER");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO REMOVE BLOCKED USER\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)deletePost:(RJManagedObjectPost *)post remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    __block NSString *postId = post.objectId;
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    [context deleteObject:post];
    
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:postId block:^(PFObject *object, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectPost *remotePost = (RJRemoteObjectPost *)object;
                remotePost.deleted = YES;
                [object saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY DELETED POST");
                        if (remoteSuccess) {
                            remoteSuccess(YES);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO DELETE POST\n%@", [error localizedDescription]);
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)deleteLike:(RJManagedObjectLike *)like withPost:(RJManagedObjectPost *)post remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    __block NSString *likeId = like.objectId;
    
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    [context deleteObject:like];
    
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:post.objectId block:^(PFObject *remotePost, NSError *error) {
            if (error) {
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                [[RJRemoteObjectLike query] getObjectInBackgroundWithId:likeId block:^(PFObject *remoteLike, NSError *error) {
                    if (error || !remoteLike) {
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        [remotePost removeObject:remoteLike forKey:@"likes"];
                        [remotePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY REMOVE LIKE FROM POST");
                                RJRemoteObjectLike *remoteLikeObject = (RJRemoteObjectLike *)remoteLike;
                                remoteLikeObject.deleted = YES;
                                [remoteLikeObject saveEventually:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY DELETED LIKE");
                                        if (remoteSuccess) {
                                            remoteSuccess(YES);
                                        }
                                    } else {
                                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO DELETE LIKE\n%@", [error localizedDescription]);
                                        if (remoteSuccess) {
                                            remoteSuccess(NO);
                                        }
                                    }
                                }];
                            } else {
                                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO REMOVE LIKE FROM POST\n%@", [error localizedDescription]);
                                if (remoteSuccess) {
                                    remoteSuccess(NO);
                                }
                            }
                        }];
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)createPostWithName:(NSString *)name longDescription:(NSString *)longDescription images:(NSArray *)images existingCategories:(NSArray *)existingCategories createdCategories:(NSArray *)createdCategories forSale:(BOOL)forSale location:(CLLocation *)location locationDescription:(NSString *)locationDescription creator:(RJManagedObjectUser *)creator remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    [self createNewRemoteCategoriesForCategories:createdCategories completion:^(NSArray *remoteCategories) {
        if (remoteCategories) {
            [self createNewLocalCategoriesForRemoteCategories:remoteCategories completion:^(NSArray *localCategories) {
                NSMutableArray *mergedLocalCategories = [[NSMutableArray alloc] init];
                [mergedLocalCategories addObjectsFromArray:localCategories];
                [mergedLocalCategories addObjectsFromArray:existingCategories];
                if (remoteCategories) {
                    [self fetchRemoteCategoriesWithCompletion:^(NSArray *objects) {
                        NSArray *remoteCategories = objects;
                        if (objects) {
                            NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
                            RJManagedObjectPost *localPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
                            localPost.createdAt = [NSDate date];
                            [self updateLocalPost:localPost withName:name creator:creator longDescription:longDescription localCategories:mergedLocalCategories forSale:forSale location:location locationDescription:locationDescription completion:^{
                                RJRemoteObjectPost *remotePost = [RJRemoteObjectPost object];
                                remotePost.appIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                                [self updateRemotePost:remotePost withName:name longDescription:longDescription forSale:forSale remoteCategories:remoteCategories localCategories:mergedLocalCategories location:location locationDescription:locationDescription localCreator:creator completion:^(BOOL success) {
                                    [self prepareImages:images remotePost:remotePost forSaveWithCompletion:^(NSArray *images) {
                                        if (images) {
                                            [self updateRemotePost:remotePost withImages:images completion:^(BOOL succeeded) {
                                                if (succeeded) {
                                                    [self updateLocalPost:localPost withImages:images completion:^(BOOL succeeded) {
                                                        if (succeeded) {
                                                            [self updateLocalPost:localPost withRemoteObjectId:remotePost.objectId completion:^(BOOL succeeded) {
                                                                if (succeeded) {
                                                                    [self saveLocalPost:localPost completion:^(BOOL success) {
                                                                        if (succeeded && remoteSuccess) {
                                                                            remoteSuccess(YES);
                                                                        } else if (remoteSuccess) {
                                                                            [self deleteManagedObject:localPost completion:^(BOOL succeeded) {
                                                                                remoteSuccess(NO);
                                                                            }];
                                                                        }
                                                                    }];
                                                                } else if (remoteSuccess) {
                                                                    [self deleteManagedObject:localPost completion:^(BOOL succeeded) {
                                                                        remoteSuccess(NO);
                                                                    }];
                                                                }
                                                            }];
                                                        } else if (remoteSuccess) {
                                                            [self deleteManagedObject:localPost completion:^(BOOL succeeded) {
                                                                remoteSuccess(NO);
                                                            }];
                                                        }
                                                    }];
                                                } else if (remoteSuccess) {
                                                    [self deleteManagedObject:localPost completion:^(BOOL succeeded) {
                                                        remoteSuccess(NO);
                                                    }];
                                                }
                                            }];
                                        } else if (remoteSuccess) {
                                            [self deleteManagedObject:localPost completion:^(BOOL succeeded) {
                                                remoteSuccess(NO);
                                            }];
                                        }
                                    }];
                                }];
                            }];
                        } else if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    }];
                } else if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            }];
        } else if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }];
}

- (void)updatePost:(RJManagedObjectPost *)post withName:(NSString *)name longDescription:(NSString *)longDescription images:(NSArray *)images existingCategories:(NSArray *)existingCategories createdCategories:(NSArray *)createdCategories forSale:(BOOL)forSale location:(CLLocation *)location locationDescription:(NSString *)locationDescription creator:(RJManagedObjectUser *)creator remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess {
    RJManagedObjectPost *localPost = post;
    [self createNewRemoteCategoriesForCategories:createdCategories completion:^(NSArray *remoteCategories) {
        if (remoteCategories) {
            [self createNewLocalCategoriesForRemoteCategories:remoteCategories completion:^(NSArray *localCategories) {
                NSMutableArray *mergedLocalCategories = [[NSMutableArray alloc] init];
                [mergedLocalCategories addObjectsFromArray:localCategories];
                [mergedLocalCategories addObjectsFromArray:existingCategories];
                if (remoteCategories) {
                    [self updateLocalPost:localPost withName:name creator:creator longDescription:longDescription localCategories:mergedLocalCategories forSale:forSale location:location locationDescription:locationDescription completion:^{
                        [self fetchPostWithObjectId:localPost.objectId completion:^(RJRemoteObjectPost *remotePost) {
                            if (post) {
                                [self fetchRemoteCategoriesWithCompletion:^(NSArray *objects) {
                                    if (objects) {
                                        NSArray *remoteCategories = objects;
                                        [self updateRemotePost:remotePost withName:name longDescription:longDescription forSale:forSale remoteCategories:remoteCategories localCategories:mergedLocalCategories location:location locationDescription:locationDescription localCreator:creator completion:^(BOOL success) {
                                            [self prepareImages:images remotePost:remotePost forSaveWithCompletion:^(NSArray *images) {
                                                if (images) {
                                                    [self updateLocalPost:localPost withImages:images completion:^(BOOL succeeded) {
                                                        if (succeeded) {
                                                            [self updateRemotePost:remotePost withImages:images completion:^(BOOL succeeded) {
                                                                if (succeeded) {
                                                                    [self saveLocalPost:localPost completion:^(BOOL success) {
                                                                        if (remoteSuccess) {
                                                                            remoteSuccess(succeeded);
                                                                        }
                                                                    }];
                                                                } else if (remoteSuccess) {
                                                                    remoteSuccess(NO);
                                                                }
                                                            }];
                                                        } else if (remoteSuccess) {
                                                            remoteSuccess(NO);
                                                        }
                                                    }];
                                                } else if (remoteSuccess) {
                                                    remoteSuccess(NO);
                                                }
                                            }];
                                        }];
                                    } else if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                }];
                            } else if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }];
                    }];
                } else if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            }];
        } else if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }];
}

- (void)createFlagWithPost:(RJManagedObjectPost *)post
                   creator:(RJManagedObjectUser *)creator
                    reason:(RJManagedObjectFlagReason)reason
             remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess
{
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    RJManagedObjectFlag *flag = [NSEntityDescription insertNewObjectForEntityForName:@"Flag" inManagedObjectContext:context];
    flag.createdAt = [NSDate date];
    flag.creator = [RJManagedObjectUser currentUser];
    flag.post = post;
    flag.reason = @(reason);
    
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:post.objectId block:^(PFObject *remotePost, NSError *error) {
            if (error || !remotePost) {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH POST");
                
                [context deleteObject:flag];
                if (![context save:&error]) {
                    NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                }
                
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectFlag *remoteFlag = [RJRemoteObjectFlag object];
                remoteFlag.creator = [RJRemoteObjectUser currentUser];
                remoteFlag.post = (RJRemoteObjectPost *)remotePost;
                remoteFlag.reason = reason;
                
                [remoteFlag saveEventually:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO CREATE FLAG\n%@", [error localizedDescription]);
                        
                        [context deleteObject:flag];
                        if (![context save:&error]) {
                            NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                        }
                        
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY CREATED FLAG");
                        flag.objectId = remoteFlag.objectId;
                        if ([context save:&error]) {
                            if (remoteSuccess) {
                                remoteSuccess(YES);
                            }
                        } else {
                            NSLog(@"Error saving Like objectId to persistent store\n\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving new Like object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)createCommentWithPost:(RJManagedObjectPost *)post
                      creator:(RJManagedObjectUser *)creator
                         text:(NSString *)text
                remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess
{
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    RJManagedObjectComment *localComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    localComment.createdAt = [NSDate date];
    localComment.creator = [RJManagedObjectUser currentUser];
    localComment.text = text;
    [post addCommentsObject:localComment];
    
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:post.objectId block:^(PFObject *remotePost, NSError *error) {
            if (error || !remotePost) {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH POST");
                
                [context deleteObject:localComment];
                if (![context save:&error]) {
                    NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                }
                
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectComment *remoteComment = [RJRemoteObjectComment object];
                remoteComment.creator = [RJRemoteObjectUser currentUser];
                remoteComment.post = (RJRemoteObjectPost *)remotePost;
                remoteComment.text = text;
                [remoteComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO CREATE COMMENT\n%@", [error localizedDescription]);
                        
                        [context deleteObject:localComment];
                        if (![context save:&error]) {
                            NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                        }
                        
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY CREATED COMMENT");
                        localComment.objectId = remoteComment.objectId;
                        if ([context save:&error]) {
                            [remotePost addObject:remoteComment forKey:@"comments"];
                            [remotePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE POST WITH COMMENT\n%@", [error localizedDescription]);
                                    
                                    [context deleteObject:localComment];
                                    if (![context save:&error]) {
                                        NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                                    }
                                    
                                    if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                } else {
                                    NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED POST WITH COMMENT");
                                    if (remoteSuccess) {
                                        remoteSuccess(YES);
                                    }
                                }
                            }];
                        } else {
                            NSLog(@"Error saving comment objectId to persistent store\n\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving new Comment object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

- (void)createLikeWithPost:(RJManagedObjectPost *)post
                   creator:(RJManagedObjectUser *)creator
             remoteSuccess:(void (^)(BOOL succeeded))remoteSuccess
{
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSError *error = nil;
    
    RJManagedObjectLike *localLike = [NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:context];
    localLike.createdAt = [NSDate date];
    localLike.creator = [RJManagedObjectUser currentUser];
    [post addLikesObject:localLike];
    
    if ([context save:&error]) {
        [[RJRemoteObjectPost query] getObjectInBackgroundWithId:post.objectId block:^(PFObject *remotePost, NSError *error) {
            if (error || !remotePost) {
                NSLog(@"PARSE UTILS -> ERROR -> FAILED TO FETCH POST");
                
                [context deleteObject:localLike];
                if (![context save:&error]) {
                    NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                }
                
                if (remoteSuccess) {
                    remoteSuccess(NO);
                }
            } else {
                RJRemoteObjectLike *remoteLike = [RJRemoteObjectLike object];
                remoteLike.creator = [RJRemoteObjectUser currentUser];
                remoteLike.post = (RJRemoteObjectPost *)remotePost;
                [remoteLike saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"PARSE UTILS -> ERROR -> FAILED TO CREATE LIKE\n%@", [error localizedDescription]);
                        
                        [context deleteObject:localLike];
                        if (![context save:&error]) {
                            NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                        }
                        
                        if (remoteSuccess) {
                            remoteSuccess(NO);
                        }
                    } else {
                        NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY CREATED LIKE");
                        localLike.objectId = remoteLike.objectId;
                        if ([context save:&error]) {
                            [remotePost addObject:remoteLike forKey:@"likes"];
                            [remotePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"PARSE UTILS -> ERROR -> FAILED TO UPDATE POST WITH LIKE\n%@", [error localizedDescription]);
                                    
                                    [context deleteObject:localLike];
                                    if (![context save:&error]) {
                                        NSLog(@"Error deleting object after remote failure\n\n%@", [error localizedDescription]);
                                    }
                                    
                                    if (remoteSuccess) {
                                        remoteSuccess(NO);
                                    }
                                } else {
                                    NSLog(@"PARSE UTILS -> SUCCESS -> SUCCESSFULLY UPDATED POST WITH LIKE");
                                    if (remoteSuccess) {
                                        remoteSuccess(YES);
                                    }
                                }
                            }];
                        } else {
                            NSLog(@"Error saving Like objectId to persistent store\n\n%@", [error localizedDescription]);
                            if (remoteSuccess) {
                                remoteSuccess(NO);
                            }
                        }
                    }
                }];
            }
        }];
    } else {
        NSLog(@"Error saving new Like object to persistent store\n\n%@", [error localizedDescription]);
        if (remoteSuccess) {
            remoteSuccess(NO);
        }
    }
}

@end
