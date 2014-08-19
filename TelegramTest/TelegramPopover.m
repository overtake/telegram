//
//  TelegramPopover.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/5/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TelegramPopover.h"

@interface TelegramPopover()

@end

@implementation TelegramPopover
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge {
    [super showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
    
    self.isShow = YES;
}



- (void) close {
    [super close];
    self.isShow = NO;
}
@end
