//
//  TGSignalUtils.m
//  Telegram
//
//  Created by keepcoder on 27/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSignalUtils.h"
#import <SSignalKit/SSignalKit.h>
@implementation TGSignalUtils


+(SSignal *)countdownSignal:(int)count delay:(int)delay {
    return  [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        __block int value = count;
        [subscriber putNext:@(value)];
        STimer *timer = [[STimer alloc] initWithTimeout:delay repeat:true completion:^{
            value -= delay;
            [subscriber putNext:@(MAX(value, 0))];
            if (value <= 0) {
                [subscriber putCompletion];
            }
        } queue:[ASQueue mainQueue]];
        [timer start];
        return [[SBlockDisposable alloc] initWithBlock:^{
            [timer invalidate];
        }];
    }];
}

@end
