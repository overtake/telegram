/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASQueue.h"

@interface ASQueue ()
{
    bool _isMainQueue;
    bool _isGlobalQueue;
    dispatch_queue_t _asqueue;
    
    const char *_name;
}

@end

@implementation ASQueue

- (instancetype)initWithName:(const char *)name
{
    self = [super init];
    if (self != nil)
    {
        _name = name;
//        
//        self._dispatch_queue = dispatchself._dispatch_queue_create(_name, 0);
//        dispatchself._dispatch_queue_set_specific(self._dispatch_queue, _name, (void *)_name, NULL);
    }
    return self;
}



+ (ASQueue *)globalQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[ASQueue alloc] initWithName:"GlobalQueue"];
    });
    return queue;
}

+ (void)dispatchOnStageQueue:(dispatch_block_t)block {
    [[ASQueue globalQueue] dispatchOnQueue:block];
}

+ (void)dispatchOnStageQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous {
    [[ASQueue globalQueue] dispatchOnQueue:block synchronous:synchronous];
}

+ (void)dispatchOnMainQueue:(dispatch_block_t)block {
    [[ASQueue mainQueue] dispatch:block];
}

+ (void)dispatchOnMainQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous {
    if(synchronous)
        [[ASQueue mainQueue] dispatchSync:block];
    else
        [[ASQueue mainQueue] dispatch:block];
}

- (dispatch_queue_t)nativeQueue
{
    return self._dispatch_queue;
}


- (void)dispatchOnQueue:(dispatch_block_t)block
{
    [self dispatchOnQueue:block synchronous:false];
}

- (void)dispatchOnQueue:(dispatch_block_t)block synchronous:(bool)synchronous
{
    if (block == nil)
        return;
    
    if(synchronous)
        [self dispatchSync:block];
    else
        [self dispatch:block];
    
//    if (self._dispatchself._dispatch_queue != nil)
//    {
//        if (_isMainQueue)
//        {
//            if ([NSThread isMainThread]) {
//            @try {
//                     block();
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"fatal error: %@",[exception callStackSymbols]);
//                    
//#ifdef TGDEBUG
//                 //   [self alertUserWithCrash:exception];
//#endif
//                }
//                
//            }
//            
//            else if (synchronous)
//                dispatch_sync(self._dispatch_queue, ^{
//                    @try {
//                        block();
//                    }
//                    @catch (NSException *exception) {
//                         NSLog(@"fatal error: %@",[exception callStackSymbols]);
//#ifdef TGDEBUG
//                     //   [self alertUserWithCrash:exception];
//#endif
//                    }
//                    
//                });
//            else
//                dispatch_async(self._dispatch_queue, ^{
//                    @try {
//                        block();
//                    }
//                    @catch (NSException *exception) {
//                         MTLog(@"fatal error: %@",[exception callStackSymbols]);
//#ifdef TGDEBUG
//                   //     [self alertUserWithCrash:exception];
//#endif
//                    }
//                });
//        }
//        else
//        {
//            if (dispatch_get_current_queue() == self.nativeQueue)
//                @try {
//                    block();
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"fatal error: %@",[exception callStackSymbols]);
//#ifdef TGDEBUG
//                  //  [self alertUserWithCrash:exception];
//#endif
//                }
//            else if (synchronous)
//                dispatch_sync(self._dispatch_queue, ^{
//                    @try {
//                        block();
//                    }
//                    @catch (NSException *exception) {
//                         NSLog(@"fatal error: %@",[exception callStackSymbols]);
//#ifdef TGDEBUG
//                   //     [self alertUserWithCrash:exception];
//#endif
//                    }
//                });
//            else
//                dispatch_async(self._dispatch_queue, ^{
//                    @try {
//                        block();
//                    }
//                    @catch (NSException *exception) {
//                         NSLog(@"fatal error: %@",[exception callStackSymbols]);
//#ifdef TGDEBUG
//                     //   [self alertUserWithCrash:exception];
//#endif
//                    }
//                });
//        }
//    }

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
