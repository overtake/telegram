//
//  TGCalendarStickRowView.m
//  Telegram
//
//  Created by keepcoder on 30/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCalendarStickRowView.h"
#import "TGCalendarStickRowItem.h"
@implementation TGCalendarStickRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    int x = 0;
    
    const NSArray *days = @[@"Weekday.ShortMonday",@"Weekday.ShortTuesday",@"Weekday.ShortWednesday",@"Weekday.ShortThursday",@"Weekday.ShortFriday",@"Weekday.ShortSaturday",@"Weekday.ShortSunday"];
    
    for (int i = 0 ; i < 7; i++) {
        
        NSMutableAttributedString *day = [[NSMutableAttributedString alloc] init];
        
        
        [day appendString:NSLocalizedString(days[i], nil) withColor:i < 5 ? TEXT_COLOR : GRAY_TEXT_COLOR];
        
        [day setFont:TGSystemFont(13) forRange:day.range];
        [day setAlignment:NSCenterTextAlignment range:day.range];
        
        [day drawInRect:NSMakeRect(x, 0, 40, 20)];
        
        x+=40;
        
    }
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
    
    TGCalendarStickRowItem *item = (TGCalendarStickRowItem *)self.rowItem;
    
    [self.textLabel setText:item.header maxWidth:NSWidth(self.frame) - 20];
    
    [self.textLabel setFrameOrigin:NSMakePoint(6, NSHeight(self.frame) - NSHeight(self.textLabel.frame) - 5)];
}

@end
