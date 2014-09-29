//
//  CNGridViewDelegate.h
//
//  Created by cocoa:naut on 07.10.12.
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


@class CNGridView;
@class CNGridViewItem;

#pragma mark CNGridViewDelegate

@protocol CNGridViewDelegate <NSObject>
@optional
/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willHoverItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willUnhoverItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView willDeselectAllItems:(NSArray *)theSelectedItems;

/**
 ...
 */
- (void)gridViewDidDeselectAllItems:(CNGridView *)gridView;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

/**
 ...
 */
- (void)gridView:(CNGridView *)gridView didActivateContextMenuWithIndexes:(NSIndexSet *)indexSet inSection:(NSUInteger)section;

@end




#pragma mark - CNGridViewDataSource

@protocol CNGridViewDataSource <NSObject>
/**
 ...
 */
- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section;

/**
 ...
 */
- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section;


@optional
/**
 ...
 */
- (NSUInteger)numberOfSectionsInGridView:(CNGridView *)gridView;

/**
 ...
 */
- (NSString *)gridView:(CNGridView *)gridView titleForHeaderInSection:(NSInteger)section;

/**
 ...
 */
- (NSArray *)sectionIndexTitlesForGridView:(CNGridView *)gridView;

@end
