//
//  RJRemoteObjectCategory.h
//  Community
//

#import <Parse/Parse.h>

@interface RJRemoteObjectCategory : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *appIdentifier;
@property (nonatomic, assign, readonly) BOOL deleted;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;

@property (nonatomic, strong, readonly) PFRelation *followers;

@end
