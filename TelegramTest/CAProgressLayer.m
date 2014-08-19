//
//  CAProgressLayer.m
//  Messenger for Telegram
//
//  Created by keepcoder on 19.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "CAProgressLayer.h"


@implementation CAProgressLayer

-(id)init {
    if(self = [super init]) {
        self.strokeColor = NSColorFromRGB(0xffffff).CGColor;
        self.fillColor = NSColorFromRGBWithAlpha(0xffffff, 0).CGColor;
        self.lineWidth=  1;
        self.lineCap = kCALineCapSquare;
        self.fillRule = kCAFillRuleEvenOdd;
        self.strokeEnd = 0;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
    }
    
    return self;
}

-(void) computePath:(CGRect)r {
    
    CGAffineTransform t = CGAffineTransformMakeRotation(M_PI/2);
    self.path =  (__bridge CGPathRef) CFBridgingRelease(CGPathCreateWithEllipseInRect(r, &t));
    
}



-(void)showProgress:(float)progress {
    
    CABasicAnimation * swipe = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    swipe.duration = 0.25;
    
    swipe.fromValue=[NSNumber numberWithDouble:self.strokeEnd];
    swipe.toValue= [NSNumber numberWithDouble:progress];
    swipe.fillMode = kCAFillModeBackwards;
    swipe.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    swipe.removedOnCompletion=NO;
    self.strokeEnd = progress;
    [self addAnimation:swipe forKey:@"strokeEnd animation"];
}

@end
