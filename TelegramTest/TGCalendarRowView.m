//
//  TGCalendarRowView.m
//  Telegram
//
//  Created by keepcoder on 29/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCalendarRowView.h"
#import "TGCalendarRowItem.h"
@interface TGCalendarRowView ()
@property (nonatomic,assign) BOOL mouseIsDown;
@end

@implementation TGCalendarRowView

static  const int wh = 40;


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    int row = 0;
    
    
    NSInteger x = (self.item.startDay - 1) * wh;
    NSInteger y = NSHeight(self.frame) - wh - 10;
    
    for (int i = 0; i < self.item.lastDayOfMonth; i++) {
        
        if(_mouseIsDown && self.indexDayBelowMouse == i) {
            
            NSRect hrect = NSMakeRect(x + 4, y + 14, wh-8, wh-8);
            [NSColorFromRGB(0xdedede) setFill];
            
            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:hrect xRadius:NSWidth(hrect)/2.0 yRadius:NSHeight(hrect)/2.0];
            
            [path fill];
        }
        
        if((!_mouseIsDown || self.indexDayBelowMouse != self.item.selectedDay) && i+1 == self.item.selectedDay) {
            NSRect hrect = NSMakeRect(x + 4, y + 14, wh-8, wh-8);
            
            [NSColorFromRGB(0xFB2125) setFill];
            
            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:hrect xRadius:NSWidth(hrect)/2.0 yRadius:NSHeight(hrect)/2.0];
            [path fill];
        }
        
        
        
        NSMutableAttributedString *day = [[NSMutableAttributedString alloc] init];
        [day appendString:[NSString stringWithFormat:@"%d",i+1] withColor:i+1 == self.item.selectedDay || (_mouseIsDown && self.indexDayBelowMouse == i) ? [NSColor whiteColor] : TEXT_COLOR];
        
        [day setFont:i+1 == self.item.selectedDay ? TGSystemMediumFont(14) : TGSystemFont(14) forRange:day.range];
        [day setAlignment:NSCenterTextAlignment range:day.range];
        
        [day drawInRect:NSMakeRect(x, y, wh, wh)];
        
        x+=wh;
        
        row++;
        
       if(row == 7 || x == wh * 7) {
           x = 0;
           y-=wh;
           row = 0;
        }
        
        
    }
    
}



-(int)indexDayBelowMouse {
    NSPoint mouse = [self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];

    NSInteger x = (self.item.startDay - 1) * wh;
    NSInteger y = NSHeight(self.frame) - wh - 10;

    int row = 0;

    
    for (int i = 0; i < self.item.lastDayOfMonth; i++) {
        
        
        if(self.mouseInView) {
            NSRect hrect = NSMakeRect(x, y + 10, wh, wh);
            
            if((NSMinX(hrect) < mouse.x && NSMaxX(hrect) > mouse.x) && (NSMinY(hrect) < mouse.y && NSMaxY(hrect) > mouse.y)) {
                return i;
            }
        }
        
        
        x+=wh;
        
        row++;
        
        if(row == 7 || x == wh * 7) {
            x = 0;
            y-=wh;
            row = 0;
        }
    }
    
    return -1;
}

-(BOOL)mouseInView {
    return NSPointInRect([self.superview.superview convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil], self.superview.frame);
}

-(void)mouseDown:(NSEvent *)theEvent {
    self.mouseIsDown = YES;
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    self.mouseIsDown = NO;
    
    int day = self.indexDayBelowMouse + 1;
    if(self.item.dayClickHandler != nil)
    {
        self.item.dayClickHandler(self.item.month,day);
    }
    

    
}

-(void)setMouseIsDown:(BOOL)mouseIsDown {
    _mouseIsDown = mouseIsDown;
    [self setNeedsDisplay:YES];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(TGCalendarRowItem *)item {
    return (TGCalendarRowItem *)self.rowItem;
}

-(void)redrawRow {
    
    _mouseIsDown = NO;
    [super redrawRow];
    
}

@end
