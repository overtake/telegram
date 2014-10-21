//
//  NSTextView+RBLAntialiasingAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 10.03.12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//
//  Portions copyright (c) 2012 Bitswift. All rights reserved.
//  See the LICENSE file for more information.
//

#import "NSTextView+RBLAntialiasingAdditions.h"
#import "NSView+RBLAlignmentAdditions.h"
#import <objc/runtime.h>

//static void (*originalDrawRectIMP)(id, SEL, NSRect);
//
//static void fixedDrawRect (NSTextView *self, SEL _cmd, NSRect rect) {
//	CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
//
//	CGContextSetAllowsAntialiasing(context, YES);
//	CGContextSetAllowsFontSmoothing(context, YES);
//	CGContextSetAllowsFontSubpixelPositioning(context, YES);
//	CGContextSetAllowsFontSubpixelQuantization(context, YES);
//
//	if (self.superview) {
//		// NSTextView likes to fall on non-integral points sometimes -- fix
//		// that.
//		self.frame = [self.superview rbl_viewBackingAlignedRect:self.frame options:NSAlignAllEdgesNearest];
//	}
//
//	originalDrawRectIMP(self, _cmd, rect);
//}
//
//@implementation NSTextView (RBLAntialiasingAdditions)
//
//+ (void)load {
//	Method drawRect = class_getInstanceMethod(self, @selector(drawRect:));
//	originalDrawRectIMP = (void (*)(id, SEL, NSRect))method_getImplementation(drawRect);
//
//	method_setImplementation(drawRect, (IMP)&fixedDrawRect);
//}
//
//@end
