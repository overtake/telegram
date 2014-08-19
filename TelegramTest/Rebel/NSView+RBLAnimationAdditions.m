//
//  NSView+RBLAnimationAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-09-04.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSView+RBLAnimationAdditions.h"

static NSUInteger RBLAnimationContextCount = 0;

@implementation NSView (RBLAnimationAdditions)

+ (void)rbl_animate:(void (^)(void))animations {
	[self rbl_animate:animations completion:nil];
}

+ (void)rbl_animate:(void (^)(void))animations completion:(void (^)(void))completion {
	// It's not clear whether NSAnimationContext will accept a nil completion
	// block.
	if (completion == nil) completion = ^{};

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		RBLAnimationContextCount++;
		animations();
		RBLAnimationContextCount--;
	} completionHandler:completion];
}

+ (void)rbl_animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion {
	[self rbl_animate:^{
		NSAnimationContext.currentContext.duration = duration;
		animations();
	} completion:completion];
}

+ (BOOL)rbl_isInAnimationContext {
	return RBLAnimationContextCount > 0;
}

- (instancetype)rbl_animator {
	return self.class.rbl_isInAnimationContext ? self.animator : self;
}

@end
