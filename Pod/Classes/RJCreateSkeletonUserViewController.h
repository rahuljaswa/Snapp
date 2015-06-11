//
//  RJCreateSkeletonUserViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 4/23/15.
//
//

#import <UIKit/UIKit.h>


@class RJCreateSkeletonUserViewController;

@protocol RJCreateSkeletonUserViewControllerProtocol <NSObject>

- (void)createSkeletonUserViewControllerDidCreateUser:(RJCreateSkeletonUserViewController *)createSkeletonUserViewController;

@end


@interface RJCreateSkeletonUserViewController : UIViewController

@property (nonatomic, weak) id<RJCreateSkeletonUserViewControllerProtocol> delegate;

@end
