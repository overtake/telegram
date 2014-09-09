//
//  UserInfoShortTextEditView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoShortTextEditView.h"

@implementation UserInfoShortTextEditView

- (id)initWithFrame:(NSRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width - 10, 26)];
        [self.textView setBordered:NO];
        [self.textView setFocusRingType:NSFocusRingTypeNone];
        [self.textView setAutoresizingMask:NSViewWidthSizable];
        [self.textView setFrameOrigin:NSMakePoint(8, 8)];
        [self.textView setDrawsBackground:NO];
        
//        [[self.textView cell] setTruncatesLastVisibleLine:NO];
//        [[self.textView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.textView setFont:[NSFont fontWithName:@"Helvetica" size:22]];
//        [self.textView setVerticallyResizable:NO];
        [self setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}



- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}


@end
