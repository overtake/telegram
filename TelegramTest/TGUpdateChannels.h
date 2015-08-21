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

-(void)addChannel:(int)channel_id pts:(int)pts;
-(void)removeChannel:(int)channel_id;

-(void)addUpdate:(id)update;

@end
