//
//  RJRemoteObjectUser.h
//  Community
//

#import <Parse/Parse.h>


@interface RJRemoteObjectUser : PFUser

@property (nonatomic, strong, readonly) PFRelation *blockedUsers;
@property (nonatomic, strong, readonly) PFRelation *followingCategories;
@property (nonatomic, strong, readonly) PFRelation *followingUsers;

@property (nonatomic, strong) NSArray *communityMemberships;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) BOOL skeleton;
@property (nonatomic, strong) NSString *twitterDigitsUserID;

@property (nonatomic, assign) BOOL admin;

@end
