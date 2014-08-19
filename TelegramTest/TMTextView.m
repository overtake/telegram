//
//  TMTextView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextView.h"

@implementation TMTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholderPoint = NSMakePoint(5, -1);
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    if(!self.string.length && self.placeholderStr) {
        [self.placeholderStr drawAtPoint:self.placeholderPoint withAttributes:@{NSForegroundColorAttributeName: [NSColor redColor], NSFontAttributeName: self.font}];
    }
}

-(BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

@end
