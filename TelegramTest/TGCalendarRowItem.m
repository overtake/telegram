//
//  TGCalendarRowItem.m
//  Telegram
//
//  Created by keepcoder on 29/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCalendarRowItem.h"
#import "TGCalendarUtils.h"
@interface TGCalendarRowItem ()

@end

@implementation TGCalendarRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _month = object;
        
        _lastDayOfMonth = [TGCalendarUtils lastDayOfTheMonth:_month];
        
        _selectedDay = -1;
        
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        unsigned unitFlags = NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitMonth;
        NSDateComponents *components = [cal components:unitFlags fromDate:_month];
        
        
        _startDay = [TGCalendarUtils weekDay:[NSDate dateWithTimeIntervalSince1970:_month.timeIntervalSince1970 - ((components.day - 1) * 24*60*60)]];
        
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGCalendarRowView");
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    
    return NO;
}

-(int)height {
    return 200; // 40 * 5
}

@end
