//
//  TGConversationsTableView.m
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGConversationsTableView.h"

@implementation TGConversationsTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    //    if([NSScroller preferredScrollerStyle] != NSScrollerStyleLegacy) {
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.bounds.size.width - DIALOG_BORDER_WIDTH, dirtyRect.origin.y, DIALOG_BORDER_WIDTH, dirtyRect.size.height));
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint point = [theEvent locationInWindow];
    
    point = [self convertPoint:point fromView:nil];
    
    NSRange range = [self rowsInRect:NSMakeRect(point.x, point.y, 1, 1)];
    

    
    if(self.selectedItem != self.list[range.location] || [Telegram rightViewController].navigationViewController.currentController != [Telegram rightViewController].messagesViewController || [Telegram rightViewController].isModalViewActive) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:range.location] byExtendingSelection:NO];
    } else {
        [super mouseDown:theEvent];
    }

    
}


@end
