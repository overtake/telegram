//
//  TGWebpageContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageContainer.h"

@implementation TGWebpageContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [LINK_COLOR setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}

@end
