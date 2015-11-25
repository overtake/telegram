//
//  TMBottomScrollView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 24.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBottomScrollView.h"

@interface TMBottomScrollView ()
@property (nonatomic, strong) NSAttributedString *messagesCountAttributedString;
@end

@implementation TMBottomScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        
        [self addTarget:self action:@selector(clickHandler) forControlEvents:BTRControlEventLeftClick];
        
      //  [self setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        
        [self setMessagesCount:32];
    }
    return self;
}

- (void)clickHandler {
    if(_callback) {
        [self setHidden:YES];
        _callback();
    }
}

- (void)handleStateChange {
    [self setNeedsDisplay:YES];
}

- (void)setMessagesCount:(int)messagesCount {
    if(messagesCount == self->_messagesCount)
        return;
    
    self->_messagesCount = messagesCount;
    if(messagesCount) {
        self.messagesCountAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(messagesCount == 1 ? @"Messages.scrollToBottomNewMessage" : @"Messages.scrollToBottomNewMessages", nil), messagesCount] attributes:@{NSFontAttributeName: TGSystemFont(14), NSForegroundColorAttributeName: BLUE_UI_COLOR}];
    } else {
        self.messagesCountAttributedString = nil;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    [NSGraphicsContext saveGraphicsState];
    CGContextSetShouldSmoothFonts(context, TRUE);

    
//    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2) xRadius:3 yRadius:3];
//    
//    [NSColorFromRGB(0xfefefe) setFill];
//    [path fill];
//    
//    [path setLineWidth:1];
//    [NSColorFromRGB(0xe5e5e5) setStroke];
//    [path stroke];
    
    
    //ROMANOV BUGFIX
    NSRect rect = NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);
    int radius = 3;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();

    CGPathMoveToPoint(pathRef, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(pathRef, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1); //STS fixed
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(pathRef, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    
    CGPathCloseSubpath(pathRef);
    CGContextAddPath(context, pathRef);
    
    NSColor *fillColor = self.isHover ? NSColorFromRGB(0xffffff) : NSColorFromRGB(0xfdfdfd);
    NSColor *strokeColor = GRAY_BORDER_COLOR;
    
    CGContextSetRGBFillColor(context, fillColor.redComponent, fillColor.greenComponent, fillColor.blueComponent, self.isHover ?  1.f : 0.96f);
    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    
    CGContextSetRGBStrokeColor(context, strokeColor.redComponent, strokeColor.greenComponent, strokeColor.blueComponent, 1);
    CGContextAddPath(context, pathRef);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    CGPathRelease(pathRef);

    
    NSPoint point;
    point.x = self.bounds.size.width - 44 +  roundf((44 - image_ScrollDownArrow().size.width) * 0.5);
    point.y = roundf((44 - image_ScrollDownArrow().size.height) * 0.5);

    [image_ScrollDownArrow() drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    if(self.messagesCount) {
        NSSize size = [self.messagesCountAttributedString size];
        size.width = ceil(size.width);
        NSPoint point = NSMakePoint(roundf((self.bounds.size.width - 28 - size.width) / 2.f), roundf( (self.bounds.size.height - size.height) / 2.f ) + 2);
        [self.messagesCountAttributedString drawAtPoint:point];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)setHidden:(BOOL)flag {
    [super setHidden:flag];
        
    if(flag) {
        [self setMessagesCount:0];
        [self sizeToFit];
    }
}

- (void)sizeToFit {
    
    NSSize size = NSMakeSize(0, 0);
    if(self.messagesCount) {
        size = [self.messagesCountAttributedString size];
        size.width = ceil(size.width);
        size.width += 16;
    }
    
    size.width += 44;
    size.height = 44;
    
    
    [self setFrameSize:size];
  //  [self setNeedsDisplay:YES];
//    [self.layer setNeedsLayout];
//    [self.layer needsDisplay];
}

@end