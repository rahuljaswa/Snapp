//
//  RJRemoteObjectPost.h
//  Community
//

#import <Parse/Parse.h>


@class RJRemoteObjectUser;

@interface RJRemoteObjectPost : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *appIdentifier;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) RJRemoteObjectUser *creator;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) BOOL forSale;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *locationDescription;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL sold;

@end
