//
//	NSView+BTRAdditions.h
//	Originally from Rebel
//
//	Created by Justin Spahr-Summers on 2012-09-04.
//	Updated by Jonathan Willing
//	Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    BTRViewAnimationCurveEaseInOut,
    BTRViewAnimationCurveEaseIn,
    BTRViewAnimationCurveEaseOut,
    BTRViewAnimationCurveLinear
} BTRViewAnimationCurve;


// Better block-based animation and animator proxies.
@interface NSView (BTRAnimationAdditions)

// Invokes +btr_animate:completion: with a nil completion block.
+ (void)btr_animate:(void (^)(void))animations;

// Executes the given animation block within a new NSAnimationContext. When all
// animations in the group complete or are canceled, the given completion block
// (if not nil) will be invoked. Implicit animation is turned on by default.
+ (void)btr_animate:(void (^)(void))animations
		 completion:(void (^)(void))completion;

// Invokes +btr_animate:completion:, setting the animation duration of the
// context before queuing the given animations.
+ (void)btr_animateWithDuration:(NSTimeInterval)duration
					 animations:(void (^)(void))animations
					 completion:(void (^)(void))completion;

// Invokes +btr_animateWithDuration:animations:completion: with the specified
// animation curve.
+ (void)btr_animateWithDuration:(NSTimeInterval)duration
				 animationCurve:(BTRViewAnimationCurve)curve
					 animations:(void (^)(void))animations
					 completion:(void (^)(void))completion;


// If the receiver is a descendant of a clip view, then this method will
// scroll the clip view to the passed in rect, optionally using the animator
// proxy, or using the enhanced scrolling in BTRClipView, if in use.
- (void)btr_scrollRectToVisible:(NSRect)rect animated:(BOOL)animated;

@end
