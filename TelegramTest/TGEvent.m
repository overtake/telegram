//
//  TGEvent.m
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGEvent.h"
#import "TGDispatcher.h"
@implementation TGEvent

-(id)initWithEventName:(NSString *)eventName resultObject:(id)resultObject {
    if(self = [super init]) {
        
        assert(eventName != nil);
        
        _uniqueId = rand_long();
        _eventName = [eventName copy];
        _resultObject = [resultObject copy];
    }
    
    return self;
}

+(id)eventWithName:(NSString *)eventName resultObject:(id)resultObject {
    return [[self alloc] initWithEventName:eventName resultObject:resultObject];
}

-(void)dispatch {
    [TGDispatcher dispatchEvent:self onQueue:nil];
}

-(void)dispatchOnQueue:(ASQueue *)queue sync:(bool)sync {
    [TGDispatcher dispatchEvent:self onQueue:queue];
}

-(void)dealloc {
    
}

@end
