//
//  TMLayer.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCircleLayer.h"

@implementation TMCircleLayer

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"radius"]
        || [key isEqualToString:@"lineWidth"]
        || [key isEqualToString:@"strokeColor"]
        || [key isEqualToString:@"fillColor"]
        || [key isEqualToString:@"opacity"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)init {
    self = [super init];
    if(self) {
        self.fillColor = [NSColor redColor];
    }
    return self;
}

- (void)setRadius:(float)radius {
    self->_radius = radius;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, radius, radius);
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    
    CGFloat radius = (self.radius - (self.lineWidth || 0));
    NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height) xRadius:radius yRadius:radius];
    
    CGPathRef path = bezier.quartzPath;
    
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextAddPath(ctx, path);
    
    if (self.fillColor) {
        CGContextFillPath(ctx);
    }
    
    if (self.strokeColor) {
        if (self.lineWidth) {
            CGContextSetLineWidth(ctx, self.lineWidth);
        }
        
        CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    }
}
@end
