//
//  NSNotificationCenter+MainThread.h
//  FindPeople
//
//  Created by keepcoder on 06.06.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MainThread)
- (void)postNotificationNameOnMainThread:(NSString *)notificationName object:(id)notificationSender;
- (void)postNotificationNameOnMainThread:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;

- (void)postNotificationNameOnStageThread:(NSString *)notificationName object:(id)notificationSender;
- (void)postNotificationNameOnStageThread:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;

@end
