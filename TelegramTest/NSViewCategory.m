//
//  NSViewCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSViewCategory.h"
#import "TMAnimations.h"
#import "TGAnimationBlockDelegate.h"
@interface CALAyerAnimationInstance : NSObject
@end

@implementation NSView (Category)

- (void)setCenterByView:(NSView *)view {
    
    float x = roundf((view.bounds.size.width - self.bounds.size.width) / 2);
    float y = roundf((view.bounds.size.height - self.bounds.size.height) / 2);
    
    
    x+= (view.bounds.size.width * self.layer.anchorPoint.x);
    y+= (view.bounds.size.height * self.layer.anchorPoint.y);
    
    [self setFrameOrigin:NSMakePoint(x,y)];
}

- (void)setCenteredXByView:(NSView *)view {
    float x = (view.bounds.size.width - self.bounds.size.width) / 2;
    
    [self setFrameOrigin:NSMakePoint(roundf(x),NSMinY(self.frame))];
}
- (void)setCenteredYByView:(NSView *)view {
    float y = (view.bounds.size.height - self.bounds.size.height) / 2;
    
    [self setFrameOrigin:NSMakePoint(NSMinX(self.frame),roundf(y))];
}

- (CGPoint)center {
    return CGPointMake((self.frame.origin.x + roundf((self.frame.size.width / 2))),
                       (self.frame.origin.y + roundf((self.frame.size.height / 2))));
}

- (void)prepareForAnimation {
    if(self.wantsLayer) {
        [self.layer removeAllAnimations];
        return;
    }
    
    NSView *superview = self.superview;
    if(superview) {
        [self removeFromSuperview];
        [self setWantsLayer:YES];
        [superview addSubview:self];
    }
}

-(void)performShake:(dispatch_block_t)completeBlock {
    float a = 3;
    float duration = 0.04;
    
    NSBeep();
    
    [self prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self setWantsLayer:NO];
        if(completeBlock)
        {
            completeBlock();
        }
    }];
    
    [self setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.layer.position.x, self.layer.position.y) toValue:CGPointMake(a + self.layer.position.x, self.layer.position.y)] forKey:@"position"];
    [CATransaction commit];
}

- (void)setAnimation:(CAAnimation *)anim forKey:(NSString *)key {
//    if(!self.wantsLayer)
//        return;
    
    anim.delegate = instance();
    [anim setValue:self forKey:@"view"];
    [self.layer addAnimation:anim forKey:key];
}

-(void)removeFromSuperview:(BOOL)animated {
    
    if(false) {
        CAAnimation *animation = [TMAnimations fadeWithDuration:0.2 fromValue:1.0f toValue:0.0];
        
        TGAnimationBlockDelegate *block = [[TGAnimationBlockDelegate alloc] initWithLayer:self.layer];
        
        block.completion = ^(BOOL completed){
            if(completed)
                [self removeFromSuperview];
            self.layer.opacity = 1.0;
        };
        
        animation.delegate = block;
        
        [self.layer removeAnimationForKey:@"opacity"];
        
        [self.layer addAnimation:animation forKey:@"opacity"];
        
        self.layer.opacity = 0.0;

    } else {
        [self removeFromSuperview];
    }
    
}


-(void)moveWithCAAnimation:(NSPoint)position animated:(BOOL)animated {
    
    if(animated) {
        int presentX = NSMinX(self.frame);
        int presentY = NSMinY(self.frame);
        
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        
        if(presentLayer && [self.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
            presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
        }
        
        CABasicAnimation *anim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(presentX, presentY) toValue:position];
        
        
        [self.layer removeAnimationForKey:@"position"];
        [self.layer addAnimation:anim forKey:@"position"];
        [self.layer setPosition:position];

    }

    
    
    [self setFrameOrigin:position];
}

-(void)heightWithCAAnimation:(NSRect)rect animated:(BOOL)animated {
    if(animated) {
        int presentHeight = NSHeight(self.frame);
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        if(presentLayer && [self.layer animationForKey:@"bounds"]) {
            presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.removedOnCompletion = YES;
        animation.fromValue = @(presentHeight);
        animation.toValue = @(NSHeight(rect));
        [self.layer removeAnimationForKey:@"bounds"];
        [self.layer addAnimation:animation forKey:@"bounds"];
        [self.layer setFrame:rect];
    }
    
    
    [self setFrame:rect];
}



-(void)widthWithCAAnimation:(NSRect)rect animated:(BOOL)animated {
    if(animated) {
        int presentWidth = NSWidth(self.frame);
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        if(presentLayer && [self.layer animationForKey:@"bounds"]) {
            presentWidth = [[presentLayer valueForKeyPath:@"bounds.size.width"] floatValue];
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.removedOnCompletion = YES;
        animation.fromValue = @(presentWidth);
        animation.toValue = @(NSWidth(rect));
        [self.layer removeAnimationForKey:@"bounds"];
        [self.layer addAnimation:animation forKey:@"bounds"];
        [self.layer setFrame:rect];
    }
   
    
    [self setFrame:rect];
}

-(void)performCAFade:(BOOL)animated {
    
    if(animated)  {
        float presentOpacity = 1.0;
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        if(presentLayer && [self.layer animationForKey:@"opacity"]) {
            presentOpacity = [[presentLayer valueForKeyPath:@"opacity"] floatValue];
        }
        
        [self.layer removeAnimationForKey:@"opacity"];
        [self.layer addAnimation:[TMAnimations fadeWithDuration:0.2f fromValue:presentOpacity toValue:0.0f] forKey:@"opacity"];
    } else {
        [self.layer removeAnimationForKey:@"opacity"];

    }
    
    
    self.layer.opacity = 0.0;
    
}
-(void)performCAShow:(BOOL)animated {
    if(animated) {
        float presentOpacity = 0;
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        if(presentLayer && [self.layer animationForKey:@"opacity"]) {
            presentOpacity = [[presentLayer valueForKeyPath:@"opacity"] floatValue];
        }
        [self.layer removeAnimationForKey:@"opacity"];

        [self.layer addAnimation:[TMAnimations fadeWithDuration:0.2f fromValue:presentOpacity toValue:1.0f] forKey:@"opacity"];

    } else {
        [self.layer removeAnimationForKey:@"opacity"];
    }
    
    self.layer.opacity = 1.0f;
}

static CALAyerAnimationInstance *instance() {
    static CALAyerAnimationInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CALAyerAnimationInstance alloc] init];
    });
    return instance;
}

- (void)removeAllSubviews {
    while (self.subviews.count > 0) {
        [self.subviews[0] removeFromSuperview];
    }
}

- (id)superviewByClass:(NSString *)className {
    NSView *superview = self.superview;
    
    if([superview.className isEqualToString:className])
        return superview;
    
    while (superview) {
        
        superview = superview.superview;
        
        if([superview.className isEqualToString:className]) {
            return superview;
        }
        
    }
    
    return nil;
}

@end

@implementation CALAyerAnimationInstance

- (void)animationDidStart:(CABasicAnimation *)anim {
    CALayerAnimations type = [[anim valueForKey:@"type"] intValue];
    if(type == 0)
        return;
    
    NSView *view = [anim valueForKey:@"view"];
    
    switch (type) {
        case CALayerOpacityAnimation: {
            view.layer.opacity = [anim.toValue floatValue];
//            MTLog(@"log %f", [anim.toValue floatValue]);
        }
            break;
            
        case CALayerPositionAnimation: {
            CGPoint toPoint;
            NSValue *toValue = anim.toValue;
            [toValue getValue:&toPoint];
            [view setFrameOrigin:toPoint];
        }
            break;
            
        default:
            break;
    }
}





@end
