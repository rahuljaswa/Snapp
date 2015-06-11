//
//  RJImageCacheManager.m
//  Community
//

#import "RJPostImageCacheEntity.h"
#import "RJUserImageCacheEntity.h"
#import "RJImageCacheManager.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <FastImageCache/FICImageFormat.h>


@implementation RJImageCacheManager

#pragma mark - Public Protocols - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        operation.securityPolicy.allowInvalidCertificates = YES;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error fetching image: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil);
            });
        }];
        
        [operation start];
    });
}

#pragma mark - Public Class Methods

+ (NSArray *)formats {
    FICImageFormat *format1 = [[FICImageFormat alloc] init];
    format1.name = kRJPostImageFormatCard16BitBGR;
    format1.family = kRJImageFormatFamilyPost;
    format1.style = FICImageFormatStyle32BitBGRA;
    format1.imageSize = kRJPostImageSizeCard;
    format1.maximumCount = 250;
    format1.devices = FICImageFormatDevicePhone;
    format1.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format2 = [[FICImageFormat alloc] init];
    format2.name = kRJPostImageFormatCardSquare16BitBGR;
    format2.family = kRJImageFormatFamilyPost;
    format2.style = FICImageFormatStyle32BitBGRA;
    format2.imageSize = kRJPostImageSizeCard;
    format2.maximumCount = 250;
    format2.devices = FICImageFormatDevicePhone;
    format2.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format3 = [[FICImageFormat alloc] init];
    format3.name = kRJUserImageFormatCard16BitBGR40x40;
    format3.family = kRJImageFormatFamilyUser;
    format3.style = FICImageFormatStyle32BitBGRA;
    format3.imageSize = kRJUserImageSize40x40;
    format3.maximumCount = 250;
    format3.devices = FICImageFormatDevicePhone;
    format3.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format4 = [[FICImageFormat alloc] init];
    format4.name = kRJUserImageFormatCard16BitBGR80x80;
    format4.family = kRJImageFormatFamilyUser;
    format4.style = FICImageFormatStyle32BitBGRA;
    format4.imageSize = kRJUserImageSize80x80;
    format4.maximumCount = 250;
    format4.devices = FICImageFormatDevicePhone;
    format4.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    return @[format1, format2, format3, format4];
}

@end
