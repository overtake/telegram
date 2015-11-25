
//
//  TGDispatcher.m
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDispatcher.h"

@interface TGListener : NSObject
@property (nonatomic,weak) dispatch_queue_t queue;
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;

@end

@implementation TGListener

-(id)initWithQueue:(dispatch_queue_t)queue target:(id)target selector:(SEL)selector {
    if(self = [super init]) {
        _queue = queue;
        _target = target;
        _selector = selector;
    }
    
    return self;
}

-(BOOL)isEqual:(id)object {
    return object == _target;
}

@end

@implementation TGDispatcher

static NSMutableDictionary *listeners;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        listeners = [[NSMutableDictionary alloc] init];
    });
}

+(void)dispatchEvent:(TGEvent *)event onQueue:(ASQueue *)dispatchQueue sync:(bool)sync {
  
    if(dispatchQueue != nil) {
        [dispatchQueue dispatchOnQueue:^{
            [self dispatchEvent:event];
        } synchronous:sync];
    } else
        [self dispatchEvent:event];
    
    
    
}


+(void)dispatchEvent:(TGEvent *)event {
    NSMutableArray *observers = listeners[event.eventName];
    
    [observers enumerateObjectsUsingBlock:^(TGListener *listener, NSUInteger idx, BOOL *stop) {
        
        IMP imp = [listener.target methodForSelector:listener.selector];
        
        if(imp) {
            void (*func)(id, SEL, id) = (void *)imp;
            func(listener.target, listener.selector, event);
        }
        
    }];
}

+(void)dispatchEvent:(TGEvent *)event onQueue:(ASQueue *)dispatchQueue {
    [self dispatchEvent:event onQueue:dispatchQueue sync:NO];
}
+(void)dispatchEventSync:(TGEvent *)event onQueue:(ASQueue *)dispatchQueue {
    [self dispatchEvent:event onQueue:dispatchQueue sync:YES];
}


+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name {
    
    [ASQueue dispatchOnStageQueue:^{
        
        TGListener *listener = [[TGListener alloc] initWithQueue:dispatch_get_current_queue() target:target selector:selector];
        
        NSMutableArray *eventListeners = listeners[name];
        
        if(!eventListeners) {
            eventListeners = [[NSMutableArray alloc] init];
            listeners[name] = eventListeners;
        }
        
        [eventListeners addObject:listener];
        
    }];
    
    
   
    
}

+ (void)removeObserver:(id)target {
    
    [ASQueue dispatchOnStageQueue:^{
        
        [listeners enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableArray *eventListeners, BOOL *stop) {
            
            [eventListeners removeObject:target];
            
        }];
        
    }];
    
}

@end
