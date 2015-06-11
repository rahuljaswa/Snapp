//
//  RJDataMarshallerOperation.h
//  Pods
//
//  Created by Rahul Jaswa on 3/12/15.
//
//

#import <Foundation/Foundation.h>


@interface RJDataMarshallerOperation : NSOperation

- (instancetype)initWithPFObjects:(NSArray *)pfObjects relation:(RJDataMarshallerPFRelation)relation targetCategory:(RJRemoteObjectCategory *)targetCategory targetUser:(RJRemoteObjectUser *)targetUser;

@end
