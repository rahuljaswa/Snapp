//
//  RJDataMarshaller.h
//  Community
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RJDataMarshallerPFRelation) {
    kRJDataMarshallerPFRelationNone,
    kRJDataMarshallerPFRelationUserBlockedUsers,
    kRJDataMarshallerPFRelationUserFollowingUsers,
    kRJDataMarshallerPFRelationUserFollowers,
    kRJDataMarshallerPFRelationUserFollowingCategories,
    kRJDataMarshallerPFRelationCategoryFollowingUsers
};


@class RJRemoteObjectCategory;
@class RJRemoteObjectUser;

@interface RJDataMarshaller : NSObject

+ (void)updateOrCreateObjectsWithPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetCategory:(RJRemoteObjectCategory *)targetCategory targetUser:(RJRemoteObjectUser *)targetUser completion:(void (^)(void))completion;

@end
