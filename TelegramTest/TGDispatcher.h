//
//  TGDispatcher.h
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGEvent.h"
@interface TGDispatcher : NSObject

+(void)dispatchEvent:(TGEvent *)event onQueue:(ASQueue *)dispatchQueue;
+(void)dispatchEventSync:(TGEvent *)event onQueue:(ASQueue *)dispatchQueue;

+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name;

+ (void)removeObserver:(id)target;

@end
