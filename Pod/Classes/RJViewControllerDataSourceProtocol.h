//
//  RJViewControllerDataSourceProtocol.h
//  Community
//

#import <Foundation/Foundation.h>

@protocol RJViewControllerDataSourceProtocol <NSObject>

- (void)fetchData;
- (void)reloadWithCompletion:(void (^)(BOOL success))completion;

@end
