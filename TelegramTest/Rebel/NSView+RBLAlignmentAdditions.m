//
//  NSView+RBLAlignmentAdditions.m
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSView+RBLAlignmentAdditions.h"

@implementation NSView (RBLAlignmentAdditions)

- (NSRect)rbl_viewBackingAlignedRect:(NSRect)rect options:(NSAlignmentOptions)options {
	if (self.window != nil) {
		NSRect windowRect = [self convertRect:rect toView:nil];
		NSRect windowBackingRect = [self backingAlignedRect:windowRect options:options];
		return [self convertRect:windowBackingRect fromView:nil];
	} else {
		// Use a best guess for how to align to the backing store.
		CGFloat scaleFactor = NSScreen.mainScreen.backingScaleFactor;
		CGAffineTransform transformToBacking = CGAffineTransformMakeScale(scaleFactor, scaleFactor);

		CGRect backingRect = CGRectApplyAffineTransform(rect, transformToBacking);
		backingRect = NSIntegralRectWithOptions(backingRect, options);
		return CGRectApplyAffineTransform(backingRect, CGAffineTransformInvert(transformToBacking));
	}
}

@end
