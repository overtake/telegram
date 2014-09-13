//
//  NSViewCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSViewCategory.h"

@interface CALAyerAnimationInstance : NSObject
@end

@implementation NSView (Category)

- (void)setCenterByView:(NSView *)view {
    
    float x = (view.bounds.size.width - self.bounds.size.width) / 2;
    float y = (view.bounds.size.height - self.bounds.size.height) / 2;
    
    [self setFrameOrigin:NSMakePoint(roundf(x),roundf(y))];
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

- (void)setAnimation:(CAAnimation *)anim forKey:(NSString *)key {
//    if(!self.wantsLayer)
//        return;
    
    anim.delegate = instance();
    [anim setValue:self forKey:@"view"];
    [self.layer addAnimation:anim forKey:key];
}

static CALAyerAnimationInstance *instance() {
    static CALAyerAnimationInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CALAyerAnimationInstance alloc] init];
    });
    return instance;
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
//            DLog(@"log %f", [anim.toValue floatValue]);
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
