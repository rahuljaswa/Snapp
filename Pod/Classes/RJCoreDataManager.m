//
//  RJCoreDataManager.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJDataMarshaller.h"
#import "RJDataMarshallerOperation.h"
#import "RJRemoteObjectUser.h"


@interface RJCoreDataManager ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSOperationQueue *operationQueue;

@end


@implementation RJCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize operationQueue = _operationQueue;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Custom getters and setters

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Private Class Methods

+ (BOOL)deleteSqliteStoreAtURL:(NSURL *)sqliteStoreURL withFileManager:(NSFileManager *)manager {
    if (![[sqliteStoreURL pathExtension] isEqualToString:@"sqlite"]) {
        NSString *reason = [NSString stringWithFormat:@"*** -[%@ %@]: sqliteStoreURL does not point to a .sqlite file",
                            NSStringFromClass([self class]),
                            NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    NSString *storeDirectoryPath = [[sqliteStoreURL path] stringByDeletingLastPathComponent];
    NSString *storeFilename = [[sqliteStoreURL path] lastPathComponent];
    
    NSError *fileError;
    NSArray *storeDirectoryContents;
    storeDirectoryContents = [manager contentsOfDirectoryAtPath:storeDirectoryPath error:&fileError];
    
    BOOL result = YES;
    if (fileError) {
        NSLog(@"Error retrieving contents\n\n%@", [fileError localizedDescription]);
        result = NO;
    } else {
        NSError *regexError;
        NSString *pattern = [NSString stringWithFormat:@"\\A%@.*\\z", storeFilename];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:kNilOptions
                                                                                 error:&regexError];
        if (regexError) {
            NSLog(@"Error creating regular expression\n\n%@", [regexError localizedDescription]);
            result = NO;
        } else {
            for (NSString *filename in storeDirectoryContents) {
                NSRange filenameRange = NSMakeRange(0, [filename length]);
                NSUInteger numMatches = [regex numberOfMatchesInString:filename
                                                               options:kNilOptions
                                                                 range:filenameRange];
                if (numMatches > 0) {
                    NSString *fullFilePath = [storeDirectoryPath stringByAppendingPathComponent:filename];
                    NSError *deletionError;
                    if (![manager removeItemAtPath:fullFilePath error:&deletionError]) {
                        result = NO;
                    }
                }
            }
        }
    }
    return result;
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RJCoreDataManager alloc] init];
    });
    return manager;
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)marshallPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetUser:(RJRemoteObjectUser *)targetUser targetCategory:(RJRemoteObjectCategory *)targetCategory completion:(void (^)(void))completion {
    RJDataMarshallerOperation *operation = [[RJDataMarshallerOperation alloc] initWithPFObjects:pfObjects relation:relation targetCategory:targetCategory targetUser:targetUser];
    [operation setCompletionBlock:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
    [self.operationQueue addOperation:operation];
}

- (void)setUpCoreData {
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentsDirectoryURLS = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectoryURL = [documentsDirectoryURLS lastObject];
    NSString *storeURLPathComponent = [NSString stringWithFormat:@"%@.sqlite", [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"]];
    NSURL *storeURL = [documentsDirectoryURL URLByAppendingPathComponent:storeURLPathComponent];
    
    NSError *error = nil;
    NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                        URL:storeURL
                                                                                      error:&error];
    
    if (metadata && ![self.managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metadata]) {
        [[self class] deleteSqliteStoreAtURL:storeURL withFileManager:[NSFileManager defaultManager]];
    }
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES
                              };
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:options
                                                      error:&error];
    
    RJRemoteObjectUser *currentUser = [RJRemoteObjectUser currentUser];
    if (currentUser) {
        [self marshallPFObjects:@[currentUser] relation:kRJDataMarshallerPFRelationNone targetUser:nil targetCategory:nil completion:nil];
    }
}

@end
