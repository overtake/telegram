//
//  MessageCellDescriptionView.m
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageCellDescriptionView.h"

@implementation MessageCellDescriptionView


-(void)setString:(NSAttributedString *)string {
    self->_string = string;
    [self setNeedsDisplay:YES];
}


- (void) drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
                                          graphicsPort];
    
    CGContextSetAllowsAntialiasing(context,true);
    CGContextSetShouldSmoothFonts(context, !IS_RETINA);
    CGContextSetAllowsFontSmoothing(context,!IS_RETINA);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2) xRadius:5 yRadius:5];
    
    [NSColorFromRGBWithAlpha(0x00000, 0.4) set];
    [path fill];
    
    [self.string drawInRect:NSMakeRect(5, 5, NSWidth(dirtyRect) - 6, NSHeight(dirtyRect) - 6)];
    
}

@end
