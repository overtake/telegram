//
//  CNGridViewItem.h
//
//  Created by cocoa:naut on 06.10.12.
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

@class CNGridViewItemLayout;

APPKIT_EXTERN NSString* const kCNDefaultItemIdentifier;
#define CNItemIndexUndefined NSNotFound



#pragma mark - CNGridViewItemBase
@interface CNGridViewItemBase : NSView


#pragma mark - Reusing Grid View Items
/** @name Reusing Grid View Items */

/**
 ...
 */
@property (strong) NSString *reuseIdentifier;

/**
 ...
 */
@property (readonly, nonatomic) BOOL isReuseable;

/**
 ...
 */
- (void)prepareForReuse;

/**
 ...
 */
@property (assign) NSInteger index;

/**
 The object that the receiving item view represents 
 */
@property (assign) id representedObject;



#pragma mark - Selection and Hovering
/** @name Selection and Hovering */

/**
 ...
 */
@property (nonatomic, assign) BOOL selected;

/**
 ...
 */
@property (nonatomic, assign) BOOL selectable;

/**
 ...
 */
@property (nonatomic, assign) BOOL hovered;

/**
 ...
 */
+ (CGSize)defaultItemSize;

@end




#pragma mark - CNGridViewItem
@interface CNGridViewItem : CNGridViewItemBase

#pragma mark - Initialization
/** @name Initialization */

/**
 Creates and returns an initialized  This is the designated initializer.
 */
- (id)initWithLayout:(CNGridViewItemLayout *)layout reuseIdentifier:(NSString *)reuseIdentifier;




#pragma mark - Item Default Content
/** @name Item Default Content */

/**
 ...
 */
@property (strong) IBOutlet NSImage *itemImage;

/**
 ...
 */
@property (strong) IBOutlet NSString *itemTitle;



#pragma mark - Grid View Item Layout
/** @name Grid View Item Layout */

/**
 ...
 */
@property (nonatomic, strong) CNGridViewItemLayout *defaultLayout;

/** 
 ...
 */
@property (nonatomic, strong) CNGridViewItemLayout *hoverLayout;

/**
 ...
 */
@property (nonatomic, strong) CNGridViewItemLayout *selectionLayout;

/**
 ...
 */
@property (nonatomic, assign) BOOL useLayout;



@end
