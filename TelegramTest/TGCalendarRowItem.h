//
//  TGCalendarRowItem.h
//  Telegram
//
//  Created by keepcoder on 29/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGCalendarRowItem : TGGeneralRowItem
@property (nonatomic,strong,readonly) NSDate *month;
@property (nonatomic,assign,readonly) NSInteger lastDayOfMonth;
@property (nonatomic,assign,readonly) NSInteger startDay;
@property (nonatomic,assign) NSInteger selectedDay;

@property (nonatomic,copy) void (^dayClickHandler)(NSDate *month,NSInteger day);
@end
