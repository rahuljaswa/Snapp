//
//  RJAppDelegate.h
//  Community
//

#import <UIKit/UIKit.h>


@class RJStyleManager;
@class RJTemplateManager;

@interface RJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) RJStyleManager *styleManager;
@property (strong, nonatomic, readonly) RJTemplateManager *templateManager;

- (void)authenticateWithCompletion:(void (^)(BOOL))completion;
- (void)requestNotificationsPermissionsWithCompletion:(void (^)(void))completion;

@end
