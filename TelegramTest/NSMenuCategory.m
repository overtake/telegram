//
//  NSMenuCategory.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSMenuCategory.h"

@implementation NSMenu (Category)

- (void) popUpForView:(NSView *)view {
    [self popUpForView:view center:NO];
}

-(void)popUpForView:(NSView *)view withType:(PopUpAlignType)type {
    NSRect wc = [view convertRect: [view bounds] toView: nil];
    wc.origin.y += 3;
    
    NSSize menuSize = self.size;
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    NSRect windowRect = [NSApp mainWindow].frame;
    
    //Фикс бага когда окно находится слева и не может отрисоваться. Его нужно отрисовывать справа
    if(windowRect.origin.x + wc.origin.x + menuSize.width > screenSize.width) {
        wc.origin.x += view.bounds.size.width;
    }
    
    // Фикс бага когда окно не может отрисоваться снизу, его нужно отрисовывать сверху
    if(windowRect.origin.y + wc.origin.y - menuSize.height < 0) {
        wc.origin.y += view.bounds.size.height + menuSize.height + 8;
    }
    
    
    int x = wc.origin.x;
    int y = wc.origin.y;
    
    if(type == PopUpAlignTypeRight) {
        x+=(wc.size.width - self.size.width);
    } else if(PopUpAlignTypeCenter) {
        x+= ((wc.size.width - self.size.width)/2);
        y+= ((wc.size.height - self.size.height)/2);
    }
    
    
    NSPoint point = NSMakePoint(x, y);
    NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseUp location:point modifierFlags:0 timestamp:NSTimeIntervalSince1970 windowNumber:[view.window windowNumber]  context:nil eventNumber:0 clickCount:0 pressure:0.1];
    
    
    
    
    
    [NSMenu popUpContextMenu:self withEvent:event forView:view];
}

- (void)popUpForView:(NSView *)view center:(BOOL)center {
    NSRect wc = [view convertRect: [view bounds] toView: nil];
    wc.origin.y -= 15;
    
    NSSize menuSize = self.size;
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    NSRect windowRect = [NSApp mainWindow].frame;
    
    //Фикс бага когда окно находится слева и не может отрисоваться. Его нужно отрисовывать справа
    if(windowRect.origin.x + wc.origin.x + menuSize.width > screenSize.width) {
        wc.origin.x += view.bounds.size.width;
    }
    
    // Фикс бага когда окно не может отрисоваться снизу, его нужно отрисовывать сверху
    if(windowRect.origin.y + wc.origin.y - menuSize.height < 0) {
        wc.origin.y += view.bounds.size.height + menuSize.height + 8;
    }
    
    NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseUp location:CGPointMake(wc.origin.x+(center ? ((wc.size.width - self.size.width)/2) : 0), wc.origin.y+ (center ? wc.size.height/2 : 0)) modifierFlags:0 timestamp:NSTimeIntervalSince1970 windowNumber:[view.window windowNumber]  context:nil eventNumber:0 clickCount:0 pressure:0.1];
    
    

    
    
    [NSMenu popUpContextMenu:self withEvent:event forView:view];
}


@end
