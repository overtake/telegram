//
//  TMScrollAnimation.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMScrollAnimation : NSAnimation
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic) NSPoint originPoint;
@property (nonatomic) NSPoint targetPoint;
@property (nonatomic) NSPoint progressPoint;

- (void) stopAnimationWithScrollToTarget:(BOOL)isScrollToTarget;

//+ (void)animatedScrollPointToCenter:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView;
//+ (DuxScrollViewAnimation *)animatedScrollToPoint:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView;
@end
