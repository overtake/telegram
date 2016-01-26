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
    dispatch_queue_t _queue;
    
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
        
        _queue = dispatch_queue_create(_name, 0);
        dispatch_queue_set_specific(_queue, _name, (void *)_name, NULL);
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_HAVE_OBJC_SUPPORT
    dispatch_release(_queue);
#endif
    _queue = nil;
}

+ (ASQueue *)mainQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] init];
        queue->_queue = dispatch_get_main_queue();
        queue->_isMainQueue = true;
    });
    return queue;
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
    [[ASQueue mainQueue] dispatchOnQueue:block];
}

+ (void)dispatchOnMainQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous {
     [[ASQueue mainQueue] dispatchOnQueue:block synchronous:synchronous];
}

- (dispatch_queue_t)nativeQueue
{
    return _queue;
}

- (bool)isCurrentQueue
{
    if (_queue == nil)
        return false;
    
    if (_isMainQueue)
        return [NSThread isMainThread];
    else
        return dispatch_get_specific(_name) == _name;
}

- (void)dispatchOnQueue:(dispatch_block_t)block
{
    [self dispatchOnQueue:block synchronous:false];
}

- (void)dispatchOnQueue:(dispatch_block_t)block synchronous:(bool)synchronous
{
    if (block == nil)
        return;
    
    if (_queue != nil)
    {
        if (_isMainQueue)
        {
            if ([NSThread isMainThread]) {
            //    @try {
                     block();
            //    }
           //     @catch (NSException *exception) {
                //    MTLog(@"fatal error: %@",[exception callStackSymbols]);
                    
#ifdef TGDEBUG
                 //   [self alertUserWithCrash:exception];
#endif
           //     }
                
            }
            
            else if (synchronous)
                dispatch_sync(_queue, ^{
              //      @try {
                        block();
              //      }
                 //   @catch (NSException *exception) {
                      //   MTLog(@"fatal error: %@",[exception callStackSymbols]);
#ifdef TGDEBUG
                     //   [self alertUserWithCrash:exception];
#endif
                 //   }
                    
                });
            else
                dispatch_async(_queue, ^{
                //    @try {
                        block();
                 //   }
                  //  @catch (NSException *exception) {
                    //     MTLog(@"fatal error: %@",[exception callStackSymbols]);
#ifdef TGDEBUG
                   //     [self alertUserWithCrash:exception];
#endif
                 //   }
                });
        }
        else
        {
            if (dispatch_get_current_queue() == self.nativeQueue)
               // @try {
                    block();
              //  }
               // @catch (NSException *exception) {
                 //   MTLog(@"fatal error: %@",[exception callStackSymbols]);
#ifdef TGDEBUG
                  //  [self alertUserWithCrash:exception];
#endif
              //  }
            else if (synchronous)
                dispatch_sync(_queue, ^{
                  //  @try {
                        block();
                 //   }
                   // @catch (NSException *exception) {
                   //      MTLog(@"fatal error: %@",[exception callStackSymbols]);
#ifdef TGDEBUG
                   //     [self alertUserWithCrash:exception];
#endif
                  //  }
                });
            else
                dispatch_async(_queue, ^{
                   // @try {
                        block();
                  //  }
                  //  @catch (NSException *exception) {
                    //     MTLog(@"fatal error: %@",[exception callStackSymbols]);
#ifdef TGDEBUG
                     //   [self alertUserWithCrash:exception];
#endif
                   // }
                });
        }
    }

}

-(void)alertUserWithCrash:(NSException *)crash {
    
#ifdef TGDEBUG
    
    [ASQueue dispatchOnMainQueue:^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:appName()];
        [alert setInformativeText:[NSString stringWithFormat:@"Application throw uncaught exception: \n%@",crash]];
        
        [alert addButtonWithTitle:@"Crash application"];
        [alert addButtonWithTitle:@"Send Logs"];
        
        [alert addButtonWithTitle:@"Ignore ;("];
        [alert beginSheetModalForWindow:[[NSApp delegate] mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(crash)];
    }];
    
#endif
   
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    
    #ifdef TGDEBUG
    
    if(returnCode == 1000) {
        NSException *crash = (__bridge NSException *)(contextInfo);
        @throw crash;
    } else if(returnCode == 1001) {
        [Telegram sendLogs];
    }
    
    #endif
    
}

@end
