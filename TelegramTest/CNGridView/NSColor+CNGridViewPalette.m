//
//  NSColor+CNGridViewPalette.m
//
//  Created by cocoa:naut on 11.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2012 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "NSColor+CNGridViewPalette.h"


#if !__has_feature(objc_arc)
#error "Please use ARC for compiling this file."
#endif


@implementation NSColor (CNGridViewPalette)


#pragma mark - CNGridView Item Default Colors

+ (NSColor *)itemBackgroundColor {
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.05];
}

+ (NSColor *)itemBackgroundHoverColor {
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.1];
}

+ (NSColor *)itemBackgroundSelectionColor {
	return [NSColor colorWithCalibratedWhite:0.000 alpha:0.250];
}

+ (NSColor *)itemSelectionRingColor {
	return [NSColor colorWithCalibratedRed:0.346 green:0.531 blue:0.792 alpha:1.000];
}

+ (NSColor *)itemTitleColor {
	return [NSColor colorWithDeviceRed:0.196 green:0.200 blue:0.200 alpha:1.000];
}

+ (NSColor *)itemTitleShadowColor {
	return [NSColor colorWithDeviceWhite:1.000 alpha:0.800];
}

+ (NSColor *)selectionFrameColor {
	return [NSColor grayColor];
}

#pragma mark - Generic Stuff


#if __MAC_OS_X_VERSION_MAX_ALLOWED <= 1070
/** found at: https://gist.github.com/707921 */
- (CGColorRef)CGColor {
	const NSInteger numberOfComponents = [self numberOfComponents];
	CGFloat components[numberOfComponents];
	CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];

	[self getComponents:(CGFloat *)&components];

	return (__bridge CGColorRef)(__bridge id)CGColorCreate(colorSpace, components);
}

/** found at: https://gist.github.com/707921 */
+ (NSColor *)colorWithCGColor:(CGColorRef)CGColor {
	if (CGColor == NULL) return nil;
	return [NSColor colorWithCIColor:[CIColor colorWithCGColor:CGColor]];
}

#endif

@end
