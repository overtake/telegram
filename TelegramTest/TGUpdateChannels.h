//
//  TGUpdateChannels.h
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUpdateChannels : NSObject

-(id)initWithQueue:(ASQueue *)queue;


-(void)addUpdate:(id)update;


-(void)failUpdateWithChannelId:(int)channel_id limit:(int)limit withCallback:(void (^)(id response, TGMessageHole *longHole))callback errorCallback:(void (^)(RpcError *error))errorCallback;

@end
