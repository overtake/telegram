//
//  TGProccessUpdates.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGUpdateState.h"
@interface TGProccessUpdates : NSObject

-(void)addUpdate:(id)update;
-(void)updateDifference;
-(void)drop;

-(id)initWithQueue:(ASQueue *)queue;

-(void)resetStateAndSync;


-(void)failUpdateWithChannelId:(int)channel_id limit:(int)limit withCallback:(void (^)(id response, TGMessageHole *longHole))callback errorCallback:(void (^)(RpcError *error))errorCallback;


@end
