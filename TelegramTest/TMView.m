//
//  TMView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "HackUtils.h"

@implementation TMView

- (id) init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self initialize];
    }
    return self;
}

-(BOOL)isFlipped {
    return _isFlipped;
}

- (void) initialize {
//    self.borderColor = [NSColor clearColor];
//    self.borderSize = 1;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    
    
//    [HackUtils printMethods:self.superview];
    
//    DLog(@"window %@", self.superview);

}

-(void)setFrame:(NSRect)frame {
    
    frame = NSMakeRect(frame.origin.x, frame.origin.y, _minSize.width != 0 ? MIN(_minSize.width,frame.size.width) : frame.size.width, _minSize.height != 0 ? MIN(_minSize.height,frame.size.height) : frame.size.height);
    
    [super setFrame:frame];
}

-(void)setFrameSize:(NSSize)newSize {
    
    newSize = NSMakeSize(_minSize.width != 0 ? MIN(_minSize.width,newSize.width) : newSize.width, _minSize.height != 0 ? MIN(_minSize.height,newSize.height) : newSize.height);
    
    [super setFrameSize:newSize];
}


-(void)mouseUp:(NSEvent *)theEvent {
    if(theEvent.clickCount == 2)
        return;
    
    [super mouseUp:theEvent];
}

- (void) drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if(self.backgroundColor) {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
    
    
    
    if(self.drawBlock)
        self.drawBlock();
    
//    
//    if(self.backgroundImage)
//        [self.backgroundImage drawInRect:self.bounds fromRect:dirtyRect operation:NSCompositeSourceOver fraction:1];
//
//    if(self.border) {
//        NSBezierPath *line = [NSBezierPath bezierPath];
//        NSRect bounds = self.bounds;
//        [self.borderColor set];
//        [line setLineWidth:self.borderSize];
//        
//        if(self.border & TMViewBorderTop) {
//            [line moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
//            [line lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
//            [line stroke];
//        }
//        
//        if(self.border & TMViewBorderBottom) {
//            [line moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
//            [line lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
//            [line stroke];
//        }
//        
//        if(self.border & TMViewBorderLeft) {
//            
//            [line moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
//            [line lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
//            [line stroke];
//        }
//        
//        if(self.border & TMViewBorderRight) {
//            [line moveToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
//            [line lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
//            [line stroke];
//        }
//        [line closePath];
//    }
    
}

-(void)removeAllSubviews {
    while (self.subviews.count > 0) {
        [self.subviews[0] removeFromSuperview];
    }
}

- (void)sizeToFit {
    
}

-(void)mouseDown:(NSEvent*)theEvent {
    if(self.callback)
        self.callback();
    else {
        if(theEvent.clickCount == 2)
            return;
        [super mouseDown:theEvent];
    }
    
}

- (void)discardCursorRects {
    self.isDrawn = NO;
    [super discardCursorRects];
}

- (void)resetCursorRects {
    self.isDrawn = YES;
    [super resetCursorRects];
}

@end
