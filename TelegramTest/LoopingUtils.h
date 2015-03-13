//
//  LoopingUtils.h
//  Telegram P-Edition
//
//  Created by keepcoder on 02.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopingUtils : NSObject
+(void)runOnMainQueueWithoutDeadlocking:(void (^)(void))block;
+(void)runOnMainQueueAsync:(void (^)(void))block;


void dispatch_after_seconds(float seconds, dispatch_block_t block);
void dispatch_after_seconds_queue(float seconds, dispatch_block_t block,dispatch_queue_t queue);
@end
