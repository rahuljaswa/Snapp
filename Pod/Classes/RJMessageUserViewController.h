//
//  RJMessageUserViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 3/1/15.
//
//

#import <UIKit/UIKit.h>


@class RJMessageUserViewController;

@protocol RJMessageUserViewControllerDelegate <NSObject>

- (void)messageUserViewControllerDidPressDoneButton:(RJMessageUserViewController *)messageUserViewController;

@end


@class RJManagedObjectPost;

@interface RJMessageUserViewController : UIViewController

@property (nonatomic, weak) id<RJMessageUserViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) RJManagedObjectPost *post;
@property (nonatomic, strong, readonly) NSString *text;

- (instancetype)initWithPost:(RJManagedObjectPost *)post;

@end
