//
//  NSContactsPopover.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/25/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSContactsPopover.h"

@interface NSContactsPopover()

@end

@implementation NSContactsPopover

- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge {
    [super showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
    
    self.isOpened = YES;
}

- (void)close {
    [super close];
    
    self.isOpened = NO;
}
@end
