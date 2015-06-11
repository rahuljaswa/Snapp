//
//  RJUserCommentsViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 2/12/15.
//
//

#import "RJViewControllerDataSourceProtocol.h"
#import "RJGalleryViewController.h"


@class RJManagedObjectUser;

@interface RJUserCommentsViewController : RJGalleryViewController <RJViewControllerDataSourceProtocol>

- (instancetype)initWithCommenter:(RJManagedObjectUser *)commenter;

@end
