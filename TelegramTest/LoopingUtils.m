//
//  LoopingUtils.m
//  Telegram P-Edition
//
//  Created by keepcoder on 02.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoopingUtils.h"

@implementation LoopingUtils


+(void)runOnMainQueueWithoutDeadlocking:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


+(void)runOnMainQueueAsync:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


void dispatch_after_seconds(float seconds, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

void dispatch_after_seconds_queue(float seconds, dispatch_block_t block,dispatch_queue_t queue) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), queue, ^{
        block();
    });
}

@end
