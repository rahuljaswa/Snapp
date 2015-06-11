//
//  RJGooglePlacesAPIClient.m
//  Pods
//
//  Created by Rahul Jaswa on 4/5/15.
//
//

#import "RJGooglePlacesAPIClient.h"


@implementation RJGooglePlacesAPIClient

#pragma mark -

+ (instancetype)sharedAPIClient {
    static RJGooglePlacesAPIClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com"];
        _client = [[RJGooglePlacesAPIClient alloc] initWithBaseURL:baseURL];
    });
    return _client;
}

- (void)getCitiesWithSearchString:(NSString *)searchString success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSString *apiKey = @"AIzaSyDp0piDtaejCvs_bWaLWQ1f6DpB70Adf84";
    NSString *path = [NSString stringWithFormat:@"/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=%@", [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], apiKey];
    [self GET:path parameters:nil success:success failure:failure];
}

@end
