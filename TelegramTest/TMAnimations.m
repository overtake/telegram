//
//  TMAnimations.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/6/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAnimations.h"
#import "TGAnimationBlockDelegate.h"
#include "NSViewCategory.h"
@implementation TMAnimations

+ (CAAnimation *)fadeWithDuration:(float)duration fromValue:(float)fromValue toValue:(float)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = duration;
    animation.autoreverses = NO;
    animation.repeatCount = 0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:fromValue > toValue ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn];
    [animation setValue:@(CALayerOpacityAnimation) forKey:@"type"];
    return animation;
}

+ (CAAnimation *)shakeWithDuration:(float)duration fromValue:(CGPoint)fromValue toValue:(CGPoint)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = duration;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    
    NSValue *fromValueValue = [NSValue value:&fromValue withObjCType:@encode(CGPoint)];
    NSValue *toValueValue = [NSValue value:&toValue withObjCType:@encode(CGPoint)];

    animation.fromValue = fromValueValue;
    animation.toValue = toValueValue;
    return animation;
}

+ (CAAnimation *)postionWithDuration:(float)duration fromValue:(CGPoint)fromValue toValue:(CGPoint)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.duration = duration;
    
    NSValue *fromValueValue = [NSValue value:&fromValue withObjCType:@encode(CGPoint)];
    NSValue *toValueValue = [NSValue value:&toValue withObjCType:@encode(CGPoint)];
    
    animation.fromValue = fromValueValue;
    animation.toValue = toValueValue;
    [animation setValue:@(CALayerPositionAnimation) forKey:@"type"];
    return animation;
}

+(CAAnimation *)resizeLayer:(CALayer*)layer to:(CGSize)size
{
    // Prepare the animation from the old size to the new size
    CGRect oldBounds = layer.bounds;
    CGRect newBounds = oldBounds;
    newBounds.size = size;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    // Mac OS X
    animation.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds)];
    animation.toValue = [NSValue valueWithRect:NSRectFromCGRect(newBounds)];
    
    animation.duration = 0.2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    
    // iOS
    //animation.fromValue = [NSValue valueWithCGRect:oldBounds];
    //animation.toValue = [NSValue valueWithCGRect:newBounds];
    
    // Update the layer's bounds so the layer doesn't snap back when the animation completes.
    layer.bounds = newBounds;
    
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"bounds"];
    
    
    return animation;
}

@end
