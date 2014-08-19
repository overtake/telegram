//
//  LBProgressBar.h
//  LBProgressBar
//
//  Created by Laurin Brandner on 05.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBProgressBar : NSProgressIndicator {
    double progressOffset;
    NSTimer* animator;
}

@property (readwrite, retain) NSTimer* animator;
@property (readwrite) double progressOffset;

-(void)drawBezel;
-(void)drawProgressWithBounds:(NSRect)bounds;
-(void)drawStripesInBounds:(NSRect)bounds;
-(void)drawShadowInBounds:(NSRect)bounds;
-(NSBezierPath*)stripeWithOrigin:(NSPoint)origin bounds:(NSRect)frame;

@end
