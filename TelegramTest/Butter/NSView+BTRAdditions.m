//
//	NSView+BTRAdditions.m
//	Originally from Rebel
//
//	Created by Justin Spahr-Summers on 2012-09-04.
//	Updated by Jonathan Willing
//	Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSView+BTRAdditions.h"
#import "BTRClipView.h"
#import <QuartzCore/CAMediaTimingFunction.h>

@implementation NSView (BTRAnimationAdditions)

#pragma mark Animations

+ (void)btr_animate:(void (^)(void))animations {
	[self btr_animate:animations completion:nil];
}

+ (void)btr_animate:(void (^)(void))animations completion:(void (^)(void))completion {
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		NSAnimationContext.currentContext.allowsImplicitAnimation = YES;
		animations();
	} completionHandler:completion];
}

+ (void)btr_animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion {
	[self btr_animate:^{
		NSAnimationContext.currentContext.duration = duration;
		animations();
	} completion:completion];
}

+ (void)btr_animateWithDuration:(NSTimeInterval)duration animationCurve:(BTRViewAnimationCurve)curve animations:(void (^)(void))animations completion:(void (^)(void))completion {
	[self btr_animateWithDuration:duration animations:^{
		NSAnimationContext.currentContext.timingFunction = [self btr_timingFunctionWithCurve:curve];
		animations();
	} completion:completion];
}

- (void)btr_scrollRectToVisible:(NSRect)rect animated:(BOOL)animated {
	NSClipView *clipView = [[self enclosingScrollView] contentView];
	if (clipView == nil) {
		return;
	}
	
	if ([clipView isKindOfClass:BTRClipView.class]) {
		[(BTRClipView *)clipView scrollRectToVisible:rect animated:animated];
	} else {
		if (animated) {
			[(NSClipView *)[clipView animator] scrollRectToVisible:rect];
		} else {
			[clipView scrollRectToVisible:rect];
		}
	}
}

#pragma mark Timing

+ (CAMediaTimingFunction *)btr_timingFunctionWithCurve:(BTRViewAnimationCurve)curve {
	switch (curve) {
		case BTRViewAnimationCurveEaseInOut:
			return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			break;
		case BTRViewAnimationCurveEaseIn:
			return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
			break;
		case BTRViewAnimationCurveEaseOut:
			return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			break;
		case BTRViewAnimationCurveLinear:
			return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			break;			
		default:
			break;
	}
	
	return nil;
}

@end
