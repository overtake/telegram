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
    [LoopingUtils runOnMainQueueAsync:^{
        [self postNotificationName:notificationName object:notificationSender];
    }];
}

- (void)postNotificationNameOnMainThread:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo {

  //  MTLog(@"notification perform %@", notificationName);
    
    [LoopingUtils runOnMainQueueAsync:^{
        [self postNotificationName:notificationName  object:notificationSender userInfo:userInfo];
    }];
}
@end
