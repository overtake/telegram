//
//  TMScrollAnimation.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMScrollAnimation.h"

@implementation TMScrollAnimation
//+ (void)animatedScrollPointToCenter:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView
//{
//    NSRect visibleRect = scrollView.documentVisibleRect;
//    
//    targetPoint = NSMakePoint(targetPoint.x - (NSWidth(visibleRect) / 2), targetPoint.y - (NSHeight(visibleRect) / 2));
//    
//    [self animatedScrollToPoint:targetPoint inScrollView:scrollView];
//}

//+ (DuxScrollViewAnimation *)animatedScrollToPoint:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView
//{
//    DuxScrollViewAnimation *animation = [[DuxScrollViewAnimation alloc] initWithDuration:0.8 animationCurve:NSAnimationEaseInOut];
//    
//    animation.scrollView = scrollView;
//    animation.targetPoint = targetPoint;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        [animation startAnimation];
//    });
//    return animation;
//}

- (void) startAnimation {
    
//    [self.scrollView setHasVerticalScroller:NO];
//    [self.scrollView setHasVerticalScroller:YES];
//
    
    self.originPoint = self.scrollView.documentVisibleRect.origin;
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [super startAnimation];
 //   });
}

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    
    typedef float (^MyAnimationCurveBlock)(float, float, float);
    MyAnimationCurveBlock cubicEaseInOut = ^ float (float t, float start, float end) {
        t *= 2.;
        if (t < 1.) return end/2 * t * t * t + start - 1.f;
        t -= 2;
        return end/2*(t * t * t + 2) + start - 1.f;
    };
    
 //   dispatch_sync(dispatch_get_main_queue(), ^{
        
        NSPoint progressPoint = self.originPoint;
        progressPoint.x += cubicEaseInOut(progress, 0, self.targetPoint.x - self.originPoint.x);
        progressPoint.y += cubicEaseInOut(progress, 0, self.targetPoint.y - self.originPoint.y);
        
        progressPoint.y = ceil(progressPoint.y);
        
        self.progressPoint = progressPoint;
        [self.scrollView.contentView scrollPoint:progressPoint];
        [self.scrollView displayIfNeeded];
   // });
}

//- (void)stopAnimation {
//    [super stopAnimation];
//}

- (void) stopAnimationWithScrollToTarget:(BOOL)isScrollToTarget {
    [self stopAnimation];
    if(isScrollToTarget) {
        [self.scrollView.contentView scrollPoint:self.targetPoint];
        [self.scrollView displayIfNeeded];
    }
}

@end
