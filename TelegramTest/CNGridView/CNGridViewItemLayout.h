//
//  CNGridViewItemLayout.h
//
//  Created by cocoa:naut on 12.10.12.
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


#import <Foundation/Foundation.h>
#import "NSColor+CNGridViewPalette.h"


/**
 `CNGridViewLayout` is a wrapper class containing all neccessary layout properties a `CNGridView` can adopt.
 */


typedef enum {
    CNGridViewItemVisibleContentNothing         = 0,
    CNGridViewItemVisibleContentImage           = 1 << 0,
    CNGridViewItemVisibleContentTitle           = 1 << 1,
} CNGridViewItemVisibleContent;


@interface CNGridViewItemLayout : NSObject

/**
 The background color of the `CNGridViewItem`.
 
 You can set any known `NSColor` values, also pattern images. If this property is not used it will be set to the default value `[NSColor itemBackgroundColor]`. Also see NSColor(CNGridViewPalette).
 */
@property (nonatomic, strong) NSColor *backgroundColor;

/**
 The color of the selection ring.
 
 If this property is not used it will be set to the default value `[NSColor itemSelectionRingColor]`. Also see NSColor(CNGridViewPalette).
 */
@property (nonatomic, strong) NSColor *selectionRingColor;

/**
 ...
 */
@property (nonatomic, assign) CGFloat selectionRingLineWidth;

/**
 ...
 */
@property (nonatomic, assign) NSUInteger contentInset;

/**
 ...
 */
@property (nonatomic, assign) NSUInteger itemBorderRadius;

/**
 ...
 */
@property (strong) NSDictionary *itemTitleTextAttributes;


/**
 A bit mask that defines the content a `CNGridViewItem` should show.
 
 There are three possible values:
     typedef enum {
         CNGridViewItemVisibleContentNothing         = 0,
         CNGridViewItemVisibleContentImage           = 1 << 0,
         CNGridViewItemVisibleContentTitle           = 1 << 1,
     } CNGridViewItemVisibleContent;
 
 Default value is `CNGridViewItemVisibleContentImage | CNGridViewItemVisibleContentTitle`.
 */
@property (nonatomic, assign) CNGridViewItemVisibleContent visibleContentMask;


/** @name Creating Default Layouts */

/**
 Creates and returns an `CNGridViewItemLayout` object with default values.
 */
+ (CNGridViewItemLayout *)defaultLayout;
@end
