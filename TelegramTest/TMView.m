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

- (void)sizeToFit {
    
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
