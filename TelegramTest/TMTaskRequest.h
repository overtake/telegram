//
//  TMTimeoutRequest.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITaskRequest.h"
@interface TMTaskRequest : NSObject<TaskObserver>


ASQueue *taskQueue();

+(void)addTask:(id<ITaskRequest>)task;
+(void)removeTask:(id<ITaskRequest>)task;

+(void)executeAll;

+(NSUInteger)futureTaskId;
@end
