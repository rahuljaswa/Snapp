//
//  RJGooglePlacesAPIClient.h
//  Pods
//
//  Created by Rahul Jaswa on 4/5/15.
//
//

#import "AFHTTPRequestOperationManager.h"


@interface RJGooglePlacesAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedAPIClient;

- (void)getCitiesWithSearchString:(NSString *)searchString success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
