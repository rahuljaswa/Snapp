//
//  RJHomeViewController.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJHomeViewController;

@protocol RJHomeViewControllerDelegate <NSObject>

- (void)homeViewController:(RJHomeViewController *)homeViewController wantsAuthenticationWithCompletion:(void (^)(BOOL success))completion;

@end


@interface RJHomeViewController : UITabBarController

@property (nonatomic, weak) id<RJHomeViewControllerDelegate> homeDelegate;

- (void)reloadWithCompletion:(void (^)(BOOL success))completion;
- (void)requestAuthenticationWithCompletion:(void (^)(BOOL success))completion;

+ (instancetype)sharedInstance;

@end
