//
//  NSViewFlipper.m
//  Telegram
//
//  Created by keepcoder on 05.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSViewFlipper.h"

@implementation NSViewFlipper

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(BOOL)isFlipped {
    return NO;
}

@end
