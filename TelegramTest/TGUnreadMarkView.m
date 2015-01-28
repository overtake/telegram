//
//  TGUnreadMarkView.m
//  Telegram
//
//  Created by keepcoder on 26.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUnreadMarkView.h"

@implementation TGUnreadMarkView

static NSDictionary *attributes() {
    static NSDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:11], NSForegroundColorAttributeName:NSColorFromRGB(0xfafafa)};
    });
    return dictionary;
}

- (void)setUnreadCount:(NSString *)unreadCount {
    self->_unreadCount = unreadCount;
    NSSize size = [unreadCount sizeWithAttributes:attributes()];
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    self.undreadSize = size;
    [self draw];
}

- (void)draw {
    NSSize size = self.undreadSize;
    
    float width = MAX(22, size.width + 14);
    [self setFrameSize:NSMakeSize(width, 22)];
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    
    float center = roundf(self.bounds.size.width / 2.0);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 11)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(1, 21) toPoint:NSMakePoint(center, 21) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(self.bounds.size.width - 1, 21) toPoint:NSMakePoint(self.bounds.size.width - 1, 11) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(self.bounds.size.width - 1, 1) toPoint:NSMakePoint(center, 1) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(1, 1) toPoint:NSMakePoint(1, 11) radius:10];
    [path setLineWidth:2];
    
    
    [NSColorFromRGB(0xDC3E34) setFill];
    [path fill];
    
    [[NSColor whiteColor] set];
    [self.unreadCount drawAtPoint:NSMakePoint( roundf(center - self.undreadSize.width/2) , 4) withAttributes:attributes()];
}
@end
