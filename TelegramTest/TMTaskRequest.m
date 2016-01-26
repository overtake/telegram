//
//  TMTimeoutRequest.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTaskRequest.h"

@interface TMTaskRequest ()
@property (nonatomic,strong) NSMutableArray *tasks;

@end


@implementation TMTaskRequest


static ASQueue *queue;

ASQueue *taskQueue() {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[ASQueue alloc] initWithName:"taskQueue"];
    });
    
    return queue;
}

-(void)addTask:(id<ITaskRequest>)task {
    if(task && [_tasks indexOfObject:task] == NSNotFound) {
        [task setDelegate:self];
        [task execute];
    }
}

-(void)removeTask:(id<ITaskRequest>)task {
    [[Storage manager] removeTask:task];
    [_tasks removeObject:task];
    [task deleteTask];
}


-(void)didCompleteTaskRequest:(id)task {
    [taskQueue() dispatchOnQueue:^{
        [self removeTask:task];
    }];
}

-(void)didStartTaskRequest:(id<ITaskRequest>)task {
    [taskQueue() dispatchOnQueue:^{
        [[Storage manager] insertTask:task];
    }];
}

-(void)didCancelledTask:(id)task {
    
}


+(void)addTask:(id<ITaskRequest>)task {
    [taskQueue() dispatchOnQueue:^{
        [[TMTaskRequest instance] addTask:task];
    }];
}

+(void)executeAll {
    
    [taskQueue() dispatchOnQueue:^{
        [[Storage manager] selectTasks:^(NSArray *tasks) {
            [tasks enumerateObjectsUsingBlock:^(id<ITaskRequest> obj, NSUInteger idx, BOOL *stop) {
                [TMTaskRequest addTask:obj];
            }];
        }];
    }];
    
}

+(void)removeTask:(id<ITaskRequest>)task {
    [taskQueue() dispatchOnQueue:^{
        [[TMTaskRequest instance] removeTask:task];
    }];
}




+(id)instance {
    static TMTaskRequest * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
        instance.tasks = [[NSMutableArray alloc] init];
        
      
    });
    return instance;
}


+(NSUInteger)futureTaskId {
    NSInteger msgId = [[NSUserDefaults standardUserDefaults] integerForKey:@"request_task_id"];
    [[NSUserDefaults standardUserDefaults] setObject:@(++msgId) forKey:@"request_task_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return msgId;
}


@end
