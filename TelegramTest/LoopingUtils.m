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

@end
