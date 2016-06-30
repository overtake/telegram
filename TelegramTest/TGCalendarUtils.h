//
//  TGCalendarUtils.h
//  Telegram
//
//  Created by keepcoder on 30/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGCalendarUtils : NSObject

+ (BOOL) isSameDate:(NSDate*)d1 date:(NSDate*)d2 checkDay:(BOOL)checkDay;
+ (NSString*) dd:(NSDate*)d;
+ (NSInteger) colForDay:(NSInteger)day;
+ (NSInteger) lastDayOfTheMonth:(NSDate *)date;
+ (NSDate*) toUTC:(NSDate*)d;
+ (NSDate*) monthDay:(NSInteger)day date:(NSDate *)date;
+ (NSInteger)weekDay:(NSDate *)date;
+ (NSDate *) stepMonth:(NSInteger)dm date:(NSDate *)date;

@end
