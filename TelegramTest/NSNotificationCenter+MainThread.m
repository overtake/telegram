//
//  NSNotificationCenter+MainThread.m
//  FindPeople
//
//  Created by keepcoder on 06.06.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSNotificationCenter+MainThread.h"
#import "LoopingUtils.h"

@implementation NSNotificationCenter (MainThread)

- (void)postNotificationNameOnMainThread:(NSString *)notificationName object:(id)notificationSender {
    [ASQueue dispatchOnMainQueue:^{
        [self postNotificationName:notificationName object:notificationSender];
    }];
}

- (void)postNotificationNameOnMainThread:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo {
    [ASQueue dispatchOnMainQueue:^{
        [self postNotificationName:notificationName  object:notificationSender userInfo:userInfo];
    }];
}


- (void)postNotificationNameOnStageThread:(NSString *)notificationName object:(id)notificationSender {
    [ASQueue dispatchOnStageQueue:^{
        [self postNotificationName:notificationName object:notificationSender];
    }];
}
- (void)postNotificationNameOnStageThread:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo {
    [ASQueue dispatchOnStageQueue:^{
        [self postNotificationName:notificationName  object:notificationSender userInfo:userInfo];
    }];
}

@end
