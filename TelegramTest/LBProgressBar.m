//
//  LBProgressBar.m
//  LBProgressBar
//
//  Created by Laurin Brandner on 05.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBProgressBar.h"

#define DEFAULT_radius 10
#define DEFAULT_angle 30

#define DEFAULT_inset 2
#define DEFAULT_stripeWidth 7

#define DEFAULT_barColor [NSColor colorWithCalibratedRed:25.0/255.0 green:29.0/255.0 blue:33.0/255.0 alpha:1.0]
#define DEFAULT_lighterProgressColor [NSColor colorWithCalibratedRed:223.0/255.0 green:237.0/255.0 blue:180.0/255.0 alpha:1.0]
#define DEFAULT_darkerProgressColor [NSColor colorWithCalibratedRed:156.0/255.0 green:200.0/255.0 blue:84.0/255.0 alpha:1.0]
#define DEFAULT_lighterStripeColor [NSColor colorWithCalibratedRed:182.0/255.0 green:216.0/255.0 blue:86.0/255.0 alpha:1.0]
#define DEFAULT_darkerStripeColor [NSColor colorWithCalibratedRed:126.0/255.0 green:187.0/255.0 blue:55.0/255.0 alpha:1.0]
#define DEFAULT_shadowColor [NSColor colorWithCalibratedRed:223.0/255.0 green:238.0/255.0 blue:181.0/255.0 alpha:1.0]

@implementation LBProgressBar

@synthesize progressOffset;

#pragma mark Accessors

-(void)setDoubleValue:(double)value {
    [super setDoubleValue:value];
    if (![self isDisplayedWhenStopped] && value == [self maxValue]) {
        [self stopAnimation:self];
    }
}

-(NSTimer*)animator {
    return animator;
}

-(void)setAnimator:(NSTimer *)value {
    if (animator != value) {
        [animator invalidate];
        [animator release];
        animator = [value retain];
    }
}

#pragma mark Initialization

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.progressOffset = 0;
        self.animator = nil;
    }
    return self;
}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    self.progressOffset = 0;
    self.animator = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawShadowInBounds:(NSRect)bounds {
    [DEFAULT_shadowColor set];
    
    NSBezierPath* shadow = [NSBezierPath bezierPath];
    
    [shadow moveToPoint:NSMakePoint(0, 2)];
    [shadow lineToPoint:NSMakePoint(NSWidth(bounds), 2)];
    
    [shadow stroke];
}


-(void)drawStripesInBounds:(NSRect)frame {
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:DEFAULT_lighterStripeColor endingColor:DEFAULT_darkerStripeColor];
    NSBezierPath* allStripes = [[NSBezierPath alloc] init];
    
    for (int i = 0; i <= frame.size.width/(2*DEFAULT_stripeWidth)+(2*DEFAULT_stripeWidth); i++) {
        NSPoint origin = NSMakePoint(i*2*DEFAULT_stripeWidth+self.progressOffset, DEFAULT_inset);
//        NSRect bounds = frame;
        
        float height = frame.size.height;
        
        NSBezierPath* rect = [[NSBezierPath alloc] init];
        
        [rect moveToPoint:origin];
        [rect lineToPoint:NSMakePoint(origin.x+DEFAULT_stripeWidth, origin.y)];
        [rect lineToPoint:NSMakePoint(origin.x+DEFAULT_stripeWidth-8, origin.y+height)];
        [rect lineToPoint:NSMakePoint(origin.x-8, origin.y+height)];
        [rect lineToPoint:origin];
        
        [allStripes appendBezierPath:rect];
        [rect release];
    }
    
    //clip
    NSBezierPath* clipPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    [clipPath addClip];
    [clipPath setClip];
    
    [gradient drawInBezierPath:allStripes angle:90];
    
    [allStripes release];
    [gradient release];
}

-(void)drawBezel {
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    
    CGFloat maxX = NSMaxX(self.bounds);
    
    //white shadow
    NSBezierPath* shadow = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0.5, 0, self.bounds.size.width-1, self.bounds.size.height-1) xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    [NSBezierPath clipRect:NSMakeRect(0, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2)];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
    [shadow stroke];
    
    CGContextRestoreGState(context);
    
    //rounded rect
    NSBezierPath* roundedRect = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-1) xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    [DEFAULT_barColor set];
    [roundedRect fill];
    
    //inner glow
    CGMutablePathRef glow = CGPathCreateMutable();
    CGPathMoveToPoint(glow, NULL, DEFAULT_radius, 0);
    CGPathAddLineToPoint(glow, NULL, maxX-DEFAULT_radius, 0);
    
    [[NSColor colorWithCalibratedRed:17.0/255.0 green:20.0/255.0 blue:23.0/255.0 alpha:1.0] set];
    CGContextAddPath(context, glow);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(glow);
}

-(void)drawProgressWithBounds:(NSRect)frame {
    NSBezierPath* bounds = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:DEFAULT_lighterProgressColor endingColor:DEFAULT_darkerProgressColor];
    [gradient drawInBezierPath:bounds angle:90];
    [gradient release];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    self.progressOffset = (self.progressOffset > (2*DEFAULT_stripeWidth)-1) ? 0 : ++self.progressOffset;
    
    float distance = [self maxValue]-[self minValue];
    float value = ([self doubleValue]) ? [self doubleValue]/distance : 0;
    
    [self drawBezel];
    
    if (value) {
        NSRect bounds = NSMakeRect(DEFAULT_inset, DEFAULT_inset, self.frame.size.width*value-2*DEFAULT_inset, (self.frame.size.height-2*DEFAULT_inset)-1);
        
        [self drawProgressWithBounds:bounds];
        [self drawStripesInBounds:bounds];
        [self drawShadowInBounds:bounds];
    }
}

#pragma mark -
#pragma mark Actions

-(void)startAnimation:(id)sender {
    if (!self.animator) {
        self.animator = [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(activateAnimation:) userInfo:nil repeats:YES];
    }
}

-(void)stopAnimation:(id)sender {
    self.animator = nil;
}

-(void)activateAnimation:(NSTimer*)timer {
    [self setNeedsDisplay:YES];
}

#pragma mark -

@end
