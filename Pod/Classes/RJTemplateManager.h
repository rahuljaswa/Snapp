//
//  RJTemplateManager.h
//  Pods
//
//  Created by Rahul Jaswa on 4/17/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RJTemplateManagerType) {
    kRJTemplateManagerTypeCommunity,
    kRJTemplateManagerTypeClassifieds
};


@interface RJTemplateManager : NSObject

@property (nonatomic, assign) RJTemplateManagerType type;

+ (instancetype)sharedInstance;

@end
