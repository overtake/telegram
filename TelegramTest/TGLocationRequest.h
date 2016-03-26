//
//  TGLocationRequest.h
//  Telegram
//
//  Created by keepcoder on 25/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGLocationRequest : NSObject

-(void)startRequestLocation:(void (^)(CLLocation *location))successCallback failback:(void (^)(NSString *error))errorCallback;

-(void)startRequestLocation:(void (^)(CLLocation *location))successCallback failback:(void (^)(NSString *error))errorCallback timeout:(int)timeout;

@end
