//
//  RJManagedObjectPost.m
//  Community
//

#import "RJManagedObjectComment.h"
#import "RJManagedObjectFlag.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectLike.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectPostCategory.h"
#import "RJManagedObjectUser.h"


@implementation RJManagedObjectPost

@dynamic categories;
@dynamic comments;
@dynamic createdAt;
@dynamic creator;
@dynamic flags;
@dynamic forSale;
@dynamic images;
@dynamic latitude;
@dynamic likes;
@dynamic locationDescription;
@dynamic longDescription;
@dynamic longitude;
@dynamic name;
@dynamic objectId;
@dynamic sold;
@dynamic threads;

- (NSArray *)sortedImages {
    return [self.images sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

@end
