//
//  RJLocationViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 4/17/15.
//
//

#import "RJGalleryViewController.h"
#import "RJViewControllerDataSourceProtocol.h"


@class CLLocation;

@interface RJLocationViewController : RJGalleryViewController  <RJViewControllerDataSourceProtocol>

- (instancetype)initWithLocation:(CLLocation *)location locationDescription:(NSString *)locationDescription;

@end
