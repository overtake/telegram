//
//  TGTransformScrollView.m
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGTransformScrollView.h"

@implementation TGTransformScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)scrollWheel:(NSEvent *)event
{
    NSPoint scrollPoint = [[self contentView] bounds].origin;

    BOOL isInverted = event.isDirectionInvertedFromDevice;
    if (!isInverted)
        scrollPoint.x += ([event scrollingDeltaY] + [event scrollingDeltaX]);
    else
        scrollPoint.x -= ([event scrollingDeltaY] + [event scrollingDeltaX]);
    [[self documentView] scrollPoint: scrollPoint];
}

@end
