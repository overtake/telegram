//
//  TGPasslock.h
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGPasslock : NSObject

+(BOOL)isEnabled;

+(void)setAutoLockTime:(int)time;

+(BOOL)isLocked;

+(BOOL)isVisibility;
+(void)setVisibility:(BOOL)visibility;

+(NSString *)autoLockDescription;

+(void)appIncomeActive;
+(void)appResignActive;

+(void)forceDisable;



@end
