//
//  RJCoreDataManager.h
//  Community
//

#import "RJDataMarshaller.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class RJRemoteObjectCategory;
@class RJRemoteObjectUser;

@interface RJCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)marshallPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetUser:(RJRemoteObjectUser *)targetUser targetCategory:(RJRemoteObjectCategory *)targetCategory completion:(void (^)(void))completion;
- (void)setUpCoreData;

+ (instancetype)sharedInstance;

@end
