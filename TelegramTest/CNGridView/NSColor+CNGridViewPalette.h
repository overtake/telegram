//
//  NSColor+CNGridViewPalette.h
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


#import <Cocoa/Cocoa.h>

/**
 This is the standard `CNGridView` color palette. All colors can be overwritten by using the related properties of `CNGridView`
 or `CNGridViewItem`.
 */


@interface NSColor (CNGridViewPalette)


#pragma mark - GridView Item Colors


/** @name GridView Item Colors */

/** Returns the standard `CNGridViewItem` background color */
+ (NSColor *)itemBackgroundColor;
/** Returns the standard `CNGridViewItem` background color when the item is in mouse over state (property must be enabled) */
+ (NSColor *)itemBackgroundHoverColor;
/** Returns the standard `CNGridViewItem` background color when the item is selected */
+ (NSColor *)itemBackgroundSelectionColor;
/** Returns the standard `CNGridViewItem` selection ring color when the item is selected */
+ (NSColor *)itemSelectionRingColor;
+ (NSColor *)itemTitleColor;
+ (NSColor *)itemTitleShadowColor;
+ (NSColor *)selectionFrameColor;


#if __MAC_OS_X_VERSION_MAX_ALLOWED <= 1070
- (CGColorRef)CGColor;
+ (NSColor *)colorWithCGColor:(CGColorRef)CGColor;
#endif

@end
