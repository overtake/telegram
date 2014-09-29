//
//  CNGridView.m
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

#import <QuartzCore/QuartzCore.h>
#import "NSColor+CNGridViewPalette.h"
#import "NSView+CNGridView.h"
#import "CNGridView.h"


#if !__has_feature(objc_arc)
#error "Please use ARC for compiling this file."
#endif



#pragma mark Notifications

const int CNSingleClick = 1;
const int CNDoubleClick = 2;
const int CNTrippleClick = 3;

NSString *const CNGridViewSelectAllItemsNotification = @"CNGridViewSelectAllItems";
NSString *const CNGridViewDeSelectAllItemsNotification = @"CNGridViewDeSelectAllItems";

NSString *const CNGridViewWillHoverItemNotification = @"CNGridViewWillHoverItem";
NSString *const CNGridViewWillUnhoverItemNotification = @"CNGridViewWillUnhoverItem";
NSString *const CNGridViewWillSelectItemNotification = @"CNGridViewWillSelectItem";
NSString *const CNGridViewDidSelectItemNotification = @"CNGridViewDidSelectItem";
NSString *const CNGridViewWillDeselectItemNotification = @"CNGridViewWillDeselectItem";
NSString *const CNGridViewDidDeselectItemNotification = @"CNGridViewDidDeselectItem";
NSString *const CNGridViewWillDeselectAllItemsNotification = @"CNGridViewWillDeselectAllItems";
NSString *const CNGridViewDidDeselectAllItemsNotification = @"CNGridViewDidDeselectAllItems";
NSString *const CNGridViewDidClickItemNotification = @"CNGridViewDidClickItem";
NSString *const CNGridViewDidDoubleClickItemNotification = @"CNGridViewDidDoubleClickItem";
NSString *const CNGridViewRightMouseButtonClickedOnItemNotification = @"CNGridViewRightMouseButtonClickedOnItem";

NSString *const CNGridViewItemKey = @"gridViewItem";
NSString *const CNGridViewItemIndexKey = @"gridViewItemIndex";
NSString *const CNGridViewSelectedItemsKey = @"CNGridViewSelectedItems";
NSString *const CNGridViewItemsIndexSetKey = @"CNGridViewItemsIndexSetKey";


CNItemPoint CNMakeItemPoint(NSUInteger aColumn, NSUInteger aRow) {
	CNItemPoint point;
	point.column = aColumn;
	point.row = aRow;
	return point;
}

#pragma mark CNSelectionFrameView

@interface CNSelectionFrameView : NSView
@end

#pragma mark CNGridView


@interface CNGridView () {
	NSMutableDictionary *keyedVisibleItems;
	NSMutableDictionary *reuseableItems;
	NSMutableDictionary *selectedItems;
	NSMutableDictionary *selectedItemsBySelectionFrame;
	CNSelectionFrameView *selectionFrameView;
	NSNotificationCenter *nc;
	NSMutableArray *clickEvents;
	NSTrackingArea *gridViewTrackingArea;
	NSTimer *clickTimer;
	NSInteger lastHoveredIndex;
	NSInteger lastSelectedItemIndex;
	NSInteger numberOfItems;
	CGPoint selectionFrameInitialPoint;
	BOOL isInitialCall;
	BOOL mouseHasDragged;
	BOOL abortSelection;

	CGFloat _contentInset;
}
@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation CNGridView

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		[self setupDefaults];
		_delegate = nil;
		_dataSource = nil;
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupDefaults];
		_delegate = nil;
		_dataSource = nil;
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupDefaults];
	}
	return self;
}

- (void)setupDefaults {
	keyedVisibleItems = [[NSMutableDictionary alloc] init];
	reuseableItems = [[NSMutableDictionary alloc] init];
	selectedItems = [[NSMutableDictionary alloc] init];
	selectedItemsBySelectionFrame = [[NSMutableDictionary alloc] init];
	clickEvents = [NSMutableArray array];
	nc = [NSNotificationCenter defaultCenter];
	lastHoveredIndex = NSNotFound;
	lastSelectedItemIndex = NSNotFound;
	selectionFrameInitialPoint = CGPointZero;
	clickTimer = nil;
	isInitialCall = YES;
	abortSelection = NO;
	mouseHasDragged = NO;
	selectionFrameView = nil;


	// properties
	_backgroundColor = [NSColor controlColor];
	_itemSize = [CNGridViewItem defaultItemSize];
	_gridViewTitle = nil;
	_scrollElasticity = YES;
	_allowsSelection = YES;
	_allowsMultipleSelection = NO;
	_allowsMultipleSelectionWithDrag = NO;
	_useSelectionRing = YES;
	_useHover = YES;


	[[self enclosingScrollView] setDrawsBackground:YES];

	NSClipView *clipView = [[self enclosingScrollView] contentView];
	[clipView setPostsBoundsChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(updateVisibleRect)
	                                             name:NSViewBoundsDidChangeNotification
	                                           object:clipView];
}

#pragma mark - Accessors

- (void)setItemSize:(NSSize)itemSize {
	if (!NSEqualSizes(_itemSize, itemSize)) {
		_itemSize = itemSize;
		[self refreshGridViewAnimated:YES initialCall:YES];
	}
}

- (void)setScrollElasticity:(BOOL)scrollElasticity {
	_scrollElasticity = scrollElasticity;
	NSScrollView *scrollView = [self enclosingScrollView];
	if (_scrollElasticity) {
		[scrollView setHorizontalScrollElasticity:NSScrollElasticityAllowed];
		[scrollView setVerticalScrollElasticity:NSScrollElasticityAllowed];
	}
	else {
		[scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
		[scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
	}
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
	_backgroundColor = backgroundColor;
	[[self enclosingScrollView] setBackgroundColor:_backgroundColor];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
	_allowsMultipleSelection = allowsMultipleSelection;
	if (selectedItems.count > 0 && !allowsMultipleSelection) {
		[nc postNotificationName:CNGridViewDeSelectAllItemsNotification object:self];
		[selectedItems removeAllObjects];
	}
}

#pragma mark - Private Helper

- (void)_refreshInset {
	if (self.useCenterAlignment) {
		NSRect clippedRect  = [self clippedRect];
		NSUInteger columns  = [self columnsInGridView];
		_contentInset = floorf((clippedRect.size.width - columns * self.itemSize.width) / 2);
	}
	else {
		_contentInset = 0;
	}
}

- (void)updateVisibleRect {
	[self updateReuseableItems];
	[self updateVisibleItems];
	[self arrangeGridViewItemsAnimated:NO];
}

- (void)refreshGridViewAnimated:(BOOL)animated initialCall:(BOOL)initialCall {
	isInitialCall = initialCall;

	CGSize size = self.frame.size;
	CGFloat newHeight = [self allOverRowsInGridView] * self.itemSize.height + _contentInset * 2;
	if (ABS(newHeight - size.height) > 1) {
		size.height = newHeight;
		[super setFrameSize:size];
	}

	[self _refreshInset];
	__weak typeof(self) wSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
	    [wSelf _refreshInset];
	    [wSelf updateReuseableItems];
	    [wSelf updateVisibleItems];
	    [wSelf arrangeGridViewItemsAnimated:animated];
	});
}

- (void)updateReuseableItems {
	//Do not mark items as reusable unless there are no selected items in the grid as recycling items when doing range multiselect
	if (self.selectedIndexes.count == 0) {
		NSRange visibleItemRange = [self visibleItemRange];

		[[keyedVisibleItems allValues] enumerateObjectsUsingBlock: ^(CNGridViewItem *item, NSUInteger idx, BOOL *stop) {
		    if (!NSLocationInRange(item.index, visibleItemRange) && [item isReuseable]) {
		        [keyedVisibleItems removeObjectForKey:@(item.index)];
		        [item removeFromSuperview];
		        [item prepareForReuse];

		        NSMutableSet *reuseQueue = reuseableItems[item.reuseIdentifier];
		        if (reuseQueue == nil) {
					reuseQueue = [NSMutableSet set];
                }
		        [reuseQueue addObject:item];
		        reuseableItems[item.reuseIdentifier] = reuseQueue;
			}
		}];
	}
}

- (void)updateVisibleItems {
	NSRange visibleItemRange = [self visibleItemRange];
	NSMutableIndexSet *visibleItemIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:visibleItemRange];

	[visibleItemIndexes removeIndexes:[self indexesForVisibleItems]];

	// update all visible items
	[visibleItemIndexes enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
	    CNGridViewItem *item = [self gridView:self itemAtIndex:idx inSection:0];
	    if (item) {
	        item.index = idx;
	        if (isInitialCall) {
	            [item setAlphaValue:0.0];
	            [item setFrame:[self rectForItemAtIndex:idx]];
			}
	        [keyedVisibleItems setObject:item forKey:@(item.index)];
	        [self addSubview:item];
		}
	}];
}

- (NSIndexSet *)indexesForVisibleItems {
	__block NSMutableIndexSet *indexesForVisibleItems = [[NSMutableIndexSet alloc] init];
	[keyedVisibleItems enumerateKeysAndObjectsUsingBlock: ^(id key, CNGridViewItem *item, BOOL *stop) {
	    [indexesForVisibleItems addIndex:item.index];
	}];
	return indexesForVisibleItems;
}

- (void)arrangeGridViewItemsAnimated:(BOOL)animated {
	// on initial call (aka application startup) we will fade all items (after loading it) in
	if (isInitialCall && [keyedVisibleItems count] > 0) {
		isInitialCall = NO;

		[[NSAnimationContext currentContext] setDuration:0.35];
		[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
		    [keyedVisibleItems enumerateKeysAndObjectsUsingBlock: ^(id key, CNGridViewItem *item, BOOL *stop) {
		        [[item animator] setAlphaValue:1.0];
			}];
		} completionHandler:nil];
	}

	else if ([keyedVisibleItems count] > 0) {
		[[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
		[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
		    [keyedVisibleItems enumerateKeysAndObjectsUsingBlock: ^(id key, CNGridViewItem *item, BOOL *stop) {
		        NSRect newRect = [self rectForItemAtIndex:item.index];
		        [[item animator] setFrame:newRect];
			}];
		} completionHandler:nil];
	}
}

- (NSRange)visibleItemRange {
	NSRect clippedRect  = [self clippedRect];
	NSUInteger columns  = [self columnsInGridView];
	NSUInteger rows     = [self visibleRowsInGridView];

	NSUInteger rangeStart = 0;
	if (clippedRect.origin.y > self.itemSize.height) {
		rangeStart = (ceilf(clippedRect.origin.y / self.itemSize.height) * columns) - columns;
	}
	NSUInteger rangeLength = MIN(numberOfItems, (columns * rows) + columns);
	rangeLength = ((rangeStart + rangeLength) > numberOfItems ? numberOfItems - rangeStart : rangeLength);

	NSRange rangeForVisibleRect = NSMakeRange(rangeStart, rangeLength);
	return rangeForVisibleRect;
}

- (NSRect)rectForItemAtIndex:(NSUInteger)index {
	NSUInteger columns = [self columnsInGridView];
	NSRect itemRect = NSMakeRect((index % columns) * self.itemSize.width + _contentInset,
	                             ((index - (index % columns)) / columns) * self.itemSize.height + _contentInset,
	                             self.itemSize.width,
	                             self.itemSize.height);

	return itemRect;
}

- (NSUInteger)columnsInGridView {
	NSRect visibleRect  = [self clippedRect];
	NSUInteger columns = floorf((float)NSWidth(visibleRect) / self.itemSize.width);
	columns = (columns < 1 ? 1 : columns);
	return columns;
}

- (NSUInteger)allOverRowsInGridView {
	NSUInteger allOverRows = ceilf((float)numberOfItems / [self columnsInGridView]);
	return allOverRows;
}

- (NSUInteger)visibleRowsInGridView {
	NSRect visibleRect  = [self clippedRect];
	NSUInteger visibleRows = ceilf((float)NSHeight(visibleRect) / self.itemSize.height);
	return visibleRows;
}

- (NSRect)clippedRect {
	return [[[self enclosingScrollView] contentView] bounds];
}

- (NSUInteger)indexForItemAtLocation:(NSPoint)location {
	NSPoint point = [self convertPoint:location fromView:nil];
	NSUInteger indexForItemAtLocation;
	if (point.x > (self.itemSize.width * [self columnsInGridView] + _contentInset)) {
		indexForItemAtLocation = NSNotFound;
	}
	else {
		NSUInteger currentColumn = floor((point.x - _contentInset) / self.itemSize.width);
		NSUInteger currentRow = floor((point.y - _contentInset) / self.itemSize.height);
		indexForItemAtLocation = currentRow * [self columnsInGridView] + currentColumn;
		indexForItemAtLocation = (indexForItemAtLocation > (numberOfItems - 1) ? NSNotFound : indexForItemAtLocation);
	}
	return indexForItemAtLocation;
}

- (CNItemPoint)locationForItemAtIndex:(NSUInteger)itemIndex {
	NSUInteger columnsInGridView = [self columnsInGridView];
	NSUInteger row = floor(itemIndex / columnsInGridView) + 1;
	NSUInteger column = itemIndex - floor((row - 1) * columnsInGridView) + 1;
	CNItemPoint location = CNMakeItemPoint(column, row);
	return location;
}

#pragma mark - Creating GridView Items

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier {
	CNGridViewItem *reusableItem = nil;
	NSMutableSet *reuseQueue = reuseableItems[identifier];
	if (reuseQueue != nil && [reuseQueue count] > 0) {
		reusableItem = [reuseQueue anyObject];
		[reuseQueue removeObject:reusableItem];
		reuseableItems[identifier] = reuseQueue;
		reusableItem.representedObject = nil;
	}
	return reusableItem;
}

#pragma mark - Reloading GridView Data

- (void)reloadData {
	[self reloadDataAnimated:NO];
}

- (void)reloadDataAnimated:(BOOL)animated {
	numberOfItems = [self gridView:self numberOfItemsInSection:0];
	[keyedVisibleItems enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    [(CNGridViewItemBase *)obj removeFromSuperview];
	}];
	[keyedVisibleItems removeAllObjects];
	[reuseableItems removeAllObjects];
	[self refreshGridViewAnimated:animated initialCall:YES];
}

#pragma mark - animating KVO changes

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated {
	NSUInteger count = keyedVisibleItems.count;
	if (count) {
		NSMutableArray *affected = [NSMutableArray arrayWithCapacity:count];
		// adjust the index
		[[keyedVisibleItems allValues] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		    CNGridViewItemBase *item = (CNGridViewItemBase *)obj;
		    NSUInteger i = item.index;
		    if (i >= index) {
		        NSUInteger acount = affected.count;
		        NSUInteger insertPos = acount;
		        for (NSUInteger j = 0; j < acount; j++) {
		            CNGridViewItemBase *p = [affected objectAtIndex:j];
		            if (i > p.index) {
		                insertPos = j;
		                break;
					}
				}
		        [affected insertObject:item atIndex:insertPos];
			}
		}];

		if (affected.count) {
			for (CNGridViewItemBase *item in affected) {
				NSInteger index = item.index;
				NSInteger newIndex = index + 1;

				[keyedVisibleItems removeObjectForKey:@(index)];
				[keyedVisibleItems setObject:item forKey:@(newIndex)];
				item.index = newIndex;
			}
			if (animated) {
				[[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
				[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
				    for (CNGridViewItemBase * item in affected) {
				        NSInteger index = item.index;
				        NSRect newRect = [self rectForItemAtIndex:index];
				        [[item animator] setFrame:newRect];
					}
				} completionHandler:nil];
			}
			else {
				for (CNGridViewItemBase *item in affected) {
					NSInteger index = item.index;
					NSRect newRect = [self rectForItemAtIndex:index];
					[item setFrame:newRect];
				}
			}
		}
	}
	numberOfItems++;
	[self refreshGridViewAnimated:animated initialCall:YES];
}

- (void)insertItemsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated {
	NSUInteger first = indexes.firstIndex;
	if (NSNotFound == first) {
		return;
	}

	NSUInteger count = keyedVisibleItems.count;
	if (count) {
		NSMutableArray *affected = [NSMutableArray arrayWithCapacity:count];
		// adjust the index
		[[keyedVisibleItems allValues] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		    CNGridViewItemBase *item = (CNGridViewItemBase *)obj;
		    NSUInteger i = item.index;
		    if (i >= first) {
		        NSUInteger acount = affected.count;
		        NSUInteger insertPos = acount;
		        for (NSUInteger j = 0; j < acount; j++) {
		            CNGridViewItemBase *p = [affected objectAtIndex:j];
		            if (i > p.index) {
		                insertPos = j;
		                break;
					}
				}
		        [affected insertObject:item atIndex:insertPos];
			}
		}];

		if (affected.count) {
			for (CNGridViewItemBase *item in affected) {
				NSInteger index = item.index;

				// check the number of new index before the index;
				__block NSUInteger ncount = 0;
				[indexes enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
				    if (range.location < index) {
				        ncount += range.length;
					}
				}];

				NSInteger newIndex = index + ncount;
				[keyedVisibleItems removeObjectForKey:@(index)];
				[keyedVisibleItems setObject:item forKey:@(newIndex)];
				item.index = newIndex;
			}
			if (animated) {
				[[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
				[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
				    for (CNGridViewItemBase * item in affected) {
				        NSInteger index = item.index;
				        NSRect newRect = [self rectForItemAtIndex:index];
				        [[item animator] setFrame:newRect];
					}
				} completionHandler:nil];
			}
			else {
				for (CNGridViewItemBase *item in affected) {
					NSInteger index = item.index;
					NSRect newRect = [self rectForItemAtIndex:index];
					[item setFrame:newRect];
				}
			}
		}
	}

	numberOfItems += indexes.count;
	[self refreshGridViewAnimated:animated initialCall:NO];
}

- (void)reloadItemsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated {
	NSUInteger first = indexes.firstIndex;
	if (NSNotFound == first) {
		return;
	}

	NSUInteger count = keyedVisibleItems.count;
	if (count) {
		NSMutableArray *affected = [NSMutableArray arrayWithCapacity:count];
		// adjust the index
		[[keyedVisibleItems allValues] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		    CNGridViewItemBase *item = (CNGridViewItemBase *)obj;
		    NSUInteger i = item.index;
		    if ([indexes containsIndex:i]) {
		        NSUInteger acount = affected.count;
		        NSUInteger insertPos = acount;
		        for (NSUInteger j = 0; j < acount; j++) {
		            CNGridViewItemBase *p = [affected objectAtIndex:j];
		            if (i > p.index) {
		                insertPos = j;
		                break;
					}
				}
		        [affected insertObject:item atIndex:insertPos];
			}
		}];

		if (affected.count) {
			for (CNGridViewItemBase *item in affected) {
				NSInteger index = item.index;
				[keyedVisibleItems removeObjectForKey:@(index)];
			}
			if (animated) {
				[[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
				[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
				    for (CNGridViewItemBase * item in affected) {
				        [item setAlphaValue:1.0];
					}
				} completionHandler: ^() {
				    for (CNGridViewItemBase * item in affected) {
				        [item removeFromSuperview];
					}
				}];
			}
			else {
				for (CNGridViewItemBase *item in affected) {
					NSInteger index = item.index;
					NSRect newRect = [self rectForItemAtIndex:index];
					[item setFrame:newRect];
				}
			}
		}
	}

	isInitialCall = YES;
	[self refreshGridViewAnimated:animated initialCall:NO];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated {
	NSUInteger first = indexes.firstIndex;
	if (NSNotFound == first) {
		return;
	}

	NSUInteger count = keyedVisibleItems.count;
	if (count) {
		NSMutableArray *affected = [NSMutableArray arrayWithCapacity:count];
		// adjust the index
		[[keyedVisibleItems allValues] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		    CNGridViewItemBase *item = (CNGridViewItemBase *)obj;
		    NSUInteger i = item.index;
		    if (i >= first) {
		        NSUInteger acount = affected.count;
		        NSUInteger insertPos = acount;
		        for (NSUInteger j = 0; j < acount; j++) {
		            CNGridViewItemBase *p = [affected objectAtIndex:j];
		            if (i > p.index) {
		                insertPos = j;
		                break;
					}
				}
		        [affected insertObject:item atIndex:insertPos];
			}
		}];

		if (affected.count) {
			for (CNGridViewItemBase *item in affected) {
				NSInteger index = item.index;
				[keyedVisibleItems removeObjectForKey:@(index)];
			}
			if (animated) {
				[[NSAnimationContext currentContext] setDuration:(animated ? 0.15 : 0.0)];
				[NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
				    for (CNGridViewItemBase * item in affected) {
				        [item setAlphaValue:1.0];
					}

				} completionHandler: ^() {
				    for (CNGridViewItemBase * item in affected) {
				        [item removeFromSuperview];
					}
				}];
			}
			else {
				for (CNGridViewItemBase *item in affected) {
					[item removeFromSuperview];
					[item prepareForReuse];
					NSString *cellID = item.identifier;
					NSMutableSet *reuseQueue = reuseableItems[cellID];
					if (reuseQueue == nil)
						reuseQueue = [NSMutableSet set];
					[reuseQueue addObject:item];
                    reuseableItems[cellID] = reuseQueue;
				}
			}
		}
	}

	numberOfItems -= indexes.count;
	[self refreshGridViewAnimated:animated initialCall:NO];
}

- (void)beginUpdates {
	// no function at the moment
	// just to please the code ported from tableview
}

- (void)endUpdates {
	// no function at the moment
	// just to please the code ported from tableview
}

#pragma mark - Selection Handling

- (void)hoverItemAtIndex:(NSInteger)index {
	// inform the delegate
	[self gridView:self willHoverItemAtIndex:index inSection:0];

	lastHoveredIndex = index;
	CNGridViewItem *item = keyedVisibleItems[@(index)];
	item.hovered = YES;
}

- (void)unHoverItemAtIndex:(NSInteger)index {
	// inform the delegate
	[self gridView:self willUnhoverItemAtIndex:index inSection:0];

	CNGridViewItem *item = keyedVisibleItems[@(index)];
	item.hovered = NO;
}

- (void)selectItemAtIndex:(NSUInteger)selectedItemIndex usingModifierFlags:(NSUInteger)modifierFlags {
	if (selectedItemIndex == NSNotFound)
		return;

	CNGridViewItem *gridViewItem = nil;

	if (lastSelectedItemIndex != NSNotFound && lastSelectedItemIndex != selectedItemIndex) {
		gridViewItem = keyedVisibleItems[@(lastSelectedItemIndex)];
		[self deSelectItem:gridViewItem];
	}

	gridViewItem = keyedVisibleItems[@(selectedItemIndex)];
	if (gridViewItem) {
		if (self.allowsMultipleSelection) {
			if (!gridViewItem.selected && !(modifierFlags & NSShiftKeyMask) && !(modifierFlags & NSCommandKeyMask)) {
				//Select a single item and deselect all other items when the shift or command keys are NOT pressed.
				[self deselectAllItems];
				[self selectItem:gridViewItem];
			}

			else if (gridViewItem.selected && modifierFlags & NSCommandKeyMask) {
				//If the item clicked is already selected and the command key is down, remove it from the selection.
				[self deSelectItem:gridViewItem];
			}

			else if (!gridViewItem.selected && modifierFlags & NSCommandKeyMask) {
				//If the item clicked is NOT selected and the command key is down, add it to the selection
				[self selectItem:gridViewItem];
			}

			else if (modifierFlags & NSShiftKeyMask) {
				//Select a range of items between the current selection and the item that was clicked when the shift key is down.
				NSUInteger lastIndex = [[self selectedIndexes] lastIndex];

				//If there were no previous items selected then
				if (lastIndex == NSNotFound) {
					[self selectItem:gridViewItem];
				}
				else {
					//Find range to select
					NSUInteger high;
					NSUInteger low;

					if (((NSInteger)lastIndex - (NSInteger)selectedItemIndex) < 0) {
						high = selectedItemIndex;
						low = lastIndex;
					}
					else {
						high = lastIndex;
						low = selectedItemIndex;
					}
					high++; //Avoid off by one

					//Select all the items that are not already selected
					for (NSUInteger idx = low; idx < high; idx++) {
						gridViewItem = keyedVisibleItems[@(idx)];
						if (gridViewItem && !gridViewItem.selected) {
							[self selectItem:gridViewItem];
						}
					}
				}
			}

			else if (gridViewItem.selected) {
				[self deselectAllItems];
				[self selectItem:gridViewItem];
			}
		}

		else {
			if (modifierFlags & NSCommandKeyMask) {
				if (gridViewItem.selected) {
					[self deSelectItem:gridViewItem];
				}
				else {
					[self selectItem:gridViewItem];
				}
			}
			else {
				[self selectItem:gridViewItem];
			}
		}
		lastSelectedItemIndex = (self.allowsMultipleSelection ? NSNotFound : selectedItemIndex);
	}
}

- (void)selectAllItems {
	NSUInteger number = [self gridView:self numberOfItemsInSection:0];
	for (NSUInteger idx = 0; idx < number; idx++) {
		CNGridViewItem *item = [self gridView:self itemAtIndex:idx inSection:0];
		item.selected = YES;
		item.index = idx;
		[selectedItems setObject:item forKey:@(item.index)];
	}
}

- (void)deselectAllItems {
	if (selectedItems.count > 0) {
		// inform the delegate
		[self gridView:self willDeselectAllItems:[self selectedItems]];

		[nc postNotificationName:CNGridViewDeSelectAllItemsNotification object:self];
		[selectedItems removeAllObjects];

		// inform the delegate
		[self gridViewDidDeselectAllItems:self];
	}
}

- (void)selectItem:(CNGridViewItem *)theItem {
	if (!selectedItems[@(theItem.index)]) {
		// inform the delegate
		[self gridView:self willSelectItemAtIndex:theItem.index inSection:0];

		theItem.selected = YES;
		selectedItems[@(theItem.index)] = theItem;

		// inform the delegate
		[self gridView:self didSelectItemAtIndex:theItem.index inSection:0];
	}
}

- (void)deSelectItem:(CNGridViewItem *)theItem {
	if (selectedItems[@(theItem.index)]) {
		// inform the delegate
		[self gridView:self willDeselectItemAtIndex:theItem.index inSection:0];

		theItem.selected = NO;
		[selectedItems removeObjectForKey:@(theItem.index)];

		// inform the delegate
		[self gridView:self didDeselectItemAtIndex:theItem.index inSection:0];
	}
}

- (NSArray *)selectedItems {
	return [selectedItems allValues];
}

- (NSIndexSet *)selectedIndexes {
	NSMutableIndexSet *mutableIndex = [NSMutableIndexSet indexSet];
	for (CNGridViewItem *gridItem in[self selectedItems]) {
		[mutableIndex addIndex:gridItem.index];
	}
	return mutableIndex;
}

- (NSIndexSet *)visibleIndexes {
	return [NSIndexSet indexSetWithIndexesInRange:[self visibleItemRange]];
}

- (void)handleClicks:(NSTimer *)theTimer {
	switch ([clickEvents count]) {
		case CNSingleClick: {
			NSEvent *theEvent = [clickEvents lastObject];
			NSUInteger index = [self indexForItemAtLocation:theEvent.locationInWindow];
			[self handleSingleClickForItemAtIndex:index];
			break;
		}

		case CNDoubleClick: {
			NSUInteger indexClick1 = [self indexForItemAtLocation:[[clickEvents objectAtIndex:0] locationInWindow]];
			NSUInteger indexClick2 = [self indexForItemAtLocation:[[clickEvents objectAtIndex:1] locationInWindow]];
			if (indexClick1 == indexClick2) {
				[self handleDoubleClickForItemAtIndex:indexClick1];
			}
			else {
				[self handleSingleClickForItemAtIndex:indexClick1];
				[self handleSingleClickForItemAtIndex:indexClick2];
			}
			break;
		}

		case CNTrippleClick: {
			NSUInteger indexClick1 = [self indexForItemAtLocation:[[clickEvents objectAtIndex:0] locationInWindow]];
			NSUInteger indexClick2 = [self indexForItemAtLocation:[[clickEvents objectAtIndex:1] locationInWindow]];
			NSUInteger indexClick3 = [self indexForItemAtLocation:[[clickEvents objectAtIndex:2] locationInWindow]];
			if (indexClick1 == indexClick2 == indexClick3) {
				[self handleDoubleClickForItemAtIndex:indexClick1];
			}

			else if ((indexClick1 == indexClick2) && (indexClick1 != indexClick3)) {
				[self handleDoubleClickForItemAtIndex:indexClick1];
				[self handleSingleClickForItemAtIndex:indexClick3];
			}

			else if ((indexClick1 != indexClick2) && (indexClick2 == indexClick3)) {
				[self handleSingleClickForItemAtIndex:indexClick1];
				[self handleDoubleClickForItemAtIndex:indexClick3];
			}

			else if (indexClick1 != indexClick2 != indexClick3) {
				[self handleSingleClickForItemAtIndex:indexClick1];
				[self handleSingleClickForItemAtIndex:indexClick2];
				[self handleSingleClickForItemAtIndex:indexClick3];
			}
			break;
		}
	}
	[clickEvents removeAllObjects];
}

- (void)handleSingleClickForItemAtIndex:(NSUInteger)selectedItemIndex {
	if (selectedItemIndex == NSNotFound)
		return;

	// inform the delegate
	[self gridView:self didClickItemAtIndex:selectedItemIndex inSection:0];
}

- (void)handleDoubleClickForItemAtIndex:(NSUInteger)selectedItemIndex {
	if (selectedItemIndex == NSNotFound)
		return;

	// inform the delegate
	[self gridView:self didDoubleClickItemAtIndex:selectedItemIndex inSection:0];
}

- (void)drawSelectionFrameForMousePointerAtLocation:(NSPoint)location {
	if (!selectionFrameView) {
		selectionFrameInitialPoint = location;
		selectionFrameView = [CNSelectionFrameView new];
		selectionFrameView.frame = NSMakeRect(location.x, location.y, 0, 0);
		if (![self containsSubView:selectionFrameView])
			[self addSubview:selectionFrameView];
	}

	else {
		NSRect clippedRect = [self clippedRect];
		NSUInteger columnsInGridView = [self columnsInGridView];

		CGFloat posX = ceil((location.x > selectionFrameInitialPoint.x ? selectionFrameInitialPoint.x : location.x));
		posX = (posX < NSMinX(clippedRect) ? NSMinX(clippedRect) : posX);

		CGFloat posY = ceil((location.y > selectionFrameInitialPoint.y ? selectionFrameInitialPoint.y : location.y));
		posY = (posY < NSMinY(clippedRect) ? NSMinY(clippedRect) : posY);

		CGFloat width = (location.x > selectionFrameInitialPoint.x ? location.x - selectionFrameInitialPoint.x : selectionFrameInitialPoint.x - posX);
		width = (posX + width >= (columnsInGridView * self.itemSize.width) ? (columnsInGridView * self.itemSize.width) - posX - 1 : width);

		CGFloat height = (location.y > selectionFrameInitialPoint.y ? location.y - selectionFrameInitialPoint.y : selectionFrameInitialPoint.y - posY);
		height = (posY + height > NSMaxY(clippedRect) ? NSMaxY(clippedRect) - posY : height);

		NSRect selectionFrame = NSMakeRect(posX, posY, width, height);
		selectionFrameView.frame = selectionFrame;
	}
}

- (NSUInteger)boundIndexForItemAtLocation:(NSPoint)location {
	NSPoint point = [self convertPoint:location fromView:nil];
	NSUInteger indexForItemAtLocation;
	CGFloat currentWidth = (self.itemSize.width * [self columnsInGridView]);

	if (point.x > currentWidth)
		point.x = currentWidth;

	NSUInteger currentColumn = floor(point.x / self.itemSize.width);
	NSUInteger currentRow = floor(point.y / self.itemSize.height);
	indexForItemAtLocation = currentRow * [self columnsInGridView] + currentColumn;

	return indexForItemAtLocation;
}

- (void)selectItemsCoveredBySelectionFrame:(NSRect)selectionFrame usingModifierFlags:(NSUInteger)modifierFlags {
	NSUInteger topLeftItemIndex = [self boundIndexForItemAtLocation:[self convertPoint:NSMakePoint(NSMinX(selectionFrame), NSMinY(selectionFrame)) toView:nil]];
	NSUInteger bottomRightItemIndex = [self boundIndexForItemAtLocation:[self convertPoint:NSMakePoint(NSMaxX(selectionFrame), NSMaxY(selectionFrame)) toView:nil]];

	CNItemPoint topLeftItemPoint = [self locationForItemAtIndex:topLeftItemIndex];
	CNItemPoint bottomRightItemPoint = [self locationForItemAtIndex:bottomRightItemIndex];

	// handle all "by selection frame" selected items beeing now outside
	// the selection frame
	[[self indexesForVisibleItems] enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
	    CNGridViewItem *selectedItem = selectedItems[@(idx)];
	    CNGridViewItem *selectionFrameItem = selectedItemsBySelectionFrame[@(idx)];
	    if (selectionFrameItem) {
	        CNItemPoint itemPoint = [self locationForItemAtIndex:selectionFrameItem.index];

	        // handle all 'out of selection frame range' items
	        if ((itemPoint.row < topLeftItemPoint.row)              ||  // top edge out of range
	            (itemPoint.column > bottomRightItemPoint.column)    ||  // right edge out of range
	            (itemPoint.row > bottomRightItemPoint.row)          ||  // bottom edge out of range
	            (itemPoint.column < topLeftItemPoint.column)) {         // left edge out of range
	                                                                    // ok. before we deselect this item, lets take a look into our `keyedVisibleItems`
	                                                                    // if it there is selected too. If it so, keep it untouched!

	            // so, the current item wasn't selected, we can restore its old state (to unselected)
	            if (![selectionFrameItem isEqual:selectedItem]) {
	                selectionFrameItem.selected = NO;
	                [selectedItemsBySelectionFrame removeObjectForKey:@(selectionFrameItem.index)];
				}

	            // the current item already was selected, so reselect it.
	            else {
	                selectionFrameItem.selected = YES;
	                selectedItemsBySelectionFrame[@(selectionFrameItem.index)] = selectionFrameItem;
				}
			}
		}
	}];

	// Verify selection frame was inside gridded area
	BOOL validSelectionFrame = (NSWidth(selectionFrame) > 0) && (NSHeight(selectionFrame) > 0);

	NSUInteger columnsInGridView = [self columnsInGridView];
	NSUInteger allOverRows = ceilf((float)numberOfItems / columnsInGridView);

	topLeftItemPoint.row = MIN(topLeftItemPoint.row, allOverRows);
	topLeftItemPoint.column = MIN(topLeftItemPoint.column, columnsInGridView);
	bottomRightItemPoint.row = MIN(bottomRightItemPoint.row, allOverRows);
	bottomRightItemPoint.column = MIN(bottomRightItemPoint.column, columnsInGridView);

	// update all items that needs to be selected
	for (NSUInteger row = topLeftItemPoint.row; row <= bottomRightItemPoint.row; row++) {
		for (NSUInteger col = topLeftItemPoint.column; col <= bottomRightItemPoint.column; col++) {
			NSUInteger itemIndex = ((row - 1) * columnsInGridView + col) - 1;
			CNGridViewItem *selectedItem = selectedItems[@(itemIndex)];
			CNGridViewItem *itemToSelect = keyedVisibleItems[@(itemIndex)];
			if (itemToSelect && validSelectionFrame) {
				selectedItemsBySelectionFrame[@(itemToSelect.index)] = itemToSelect;
				if (modifierFlags & NSCommandKeyMask) {
					itemToSelect.selected = ([itemToSelect isEqual:selectedItem] ? NO : YES);
				}
				else {
					itemToSelect.selected = YES;
				}
			}
		}
	}
}

#pragma mark - Managing the Content

- (NSUInteger)numberOfVisibleItems {
	return [keyedVisibleItems count];
}

#pragma mark - NSView

- (BOOL)isFlipped {
	return YES;
}

- (void)setFrame:(NSRect)frameRect {
	BOOL animated = (self.frame.size.width == frameRect.size.width ? NO : YES);
	[super setFrame:frameRect];
	[self refreshGridViewAnimated:animated initialCall:YES];
}

- (void)updateTrackingAreas {
	if (gridViewTrackingArea)
		[self removeTrackingArea:gridViewTrackingArea];

	gridViewTrackingArea = nil;
	gridViewTrackingArea = [[NSTrackingArea alloc] initWithRect:self.frame
	                                                    options:NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
	                                                      owner:self
	                                                   userInfo:nil];
	[self addTrackingArea:gridViewTrackingArea];
}

#pragma mark - NSResponder

- (BOOL)canBecomeKeyView {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)mouseExited:(NSEvent *)theEvent {
	lastHoveredIndex = NSNotFound;
}

- (void)mouseMoved:(NSEvent *)theEvent {
	if (!self.useHover)
		return;

	NSUInteger hoverItemIndex = [self indexForItemAtLocation:theEvent.locationInWindow];
	if (hoverItemIndex != NSNotFound || hoverItemIndex != lastHoveredIndex) {
		// unhover the last hovered item
		if (lastHoveredIndex != NSNotFound && lastHoveredIndex != hoverItemIndex) {
			[self unHoverItemAtIndex:lastHoveredIndex];
		}

		// inform the delegate
		if (lastHoveredIndex != hoverItemIndex) {
			[self hoverItemAtIndex:hoverItemIndex];
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if (!self.allowsMultipleSelection || !self.allowsMultipleSelectionWithDrag)
		return;

	mouseHasDragged = YES;
	[NSCursor closedHandCursor];

	if (!abortSelection) {
		NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		[self drawSelectionFrameForMousePointerAtLocation:location];
		[self selectItemsCoveredBySelectionFrame:selectionFrameView.frame usingModifierFlags:theEvent.modifierFlags];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	[NSCursor arrowCursor];

	abortSelection = NO;

	// this happens just if we have multiselection ON and dragged the
	// mouse over items. In this case we have to handle this selection.
	if (self.allowsMultipleSelectionWithDrag && mouseHasDragged) {
		mouseHasDragged = NO;

		// remove selection frame
		[[selectionFrameView animator] setAlphaValue:0];
		[selectionFrameView removeFromSuperview];
		selectionFrameView = nil;

		// catch all newly selected items that was selected by selection frame
		[selectedItemsBySelectionFrame enumerateKeysAndObjectsUsingBlock: ^(id key, CNGridViewItem *item, BOOL *stop) {
		    if ([item selected] == YES) {
		        [self selectItem:item];
			}
		    else {
		        [self deSelectItem:item];
			}
		}];
		[selectedItemsBySelectionFrame removeAllObjects];
	}

	// otherwise it was a real click on an item
	else {
		[clickEvents addObject:theEvent];
		clickTimer = nil;
		clickTimer = [NSTimer scheduledTimerWithTimeInterval:[NSEvent doubleClickInterval] target:self selector:@selector(handleClicks:) userInfo:nil repeats:NO];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (!self.allowsSelection)
		return;

	NSPoint location = [theEvent locationInWindow];
	NSUInteger index = [self indexForItemAtLocation:location];

	if (index != NSNotFound) {
		[self selectItemAtIndex:index usingModifierFlags:theEvent.modifierFlags];
	}
	else {
		[self deselectAllItems];
	}
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	NSPoint location = [theEvent locationInWindow];
	NSUInteger index = [self indexForItemAtLocation:location];

	if (index != NSNotFound) {
		NSIndexSet *indexSet = [self selectedIndexes];
		BOOL isClickInSelection = [indexSet containsIndex:index];

		if (!isClickInSelection) {
			indexSet = [NSIndexSet indexSetWithIndex:index];
			[self deselectAllItems];
			CNGridViewItem *item = keyedVisibleItems[@(index)];
			[self selectItem:item];
		}

		if (_itemContextMenu) {
			NSEvent *fakeMouseEvent = [NSEvent mouseEventWithType:NSRightMouseDown
			                                             location:location
			                                        modifierFlags:0
			                                            timestamp:0
			                                         windowNumber:[self.window windowNumber]
			                                              context:nil
			                                          eventNumber:0
			                                           clickCount:0
			                                             pressure:0];

			for (NSMenuItem *menuItem in _itemContextMenu.itemArray) {
				[menuItem setRepresentedObject:indexSet];
			}
			[NSMenu popUpContextMenu:_itemContextMenu withEvent:fakeMouseEvent forView:self];

			// inform the delegate
			[self gridView:self didActivateContextMenuWithIndexes:indexSet inSection:0];
		}
	}
	else {
		[self deselectAllItems];
	}
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor redColor] set];
    NSRectFill(self.bounds);
}

- (void)keyDown:(NSEvent *)theEvent {
	switch ([theEvent keyCode]) {
		case 53: {  // escape
			abortSelection = YES;
			break;
		}
	}
    [super keyDown:theEvent];
}

#pragma mark - CNGridView Delegate Calls

- (void)gridView:(CNGridView *)gridView willHoverItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewWillHoverItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView willHoverItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView willUnhoverItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewWillUnhoverItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView willUnhoverItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView willSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewWillSelectItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView willSelectItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewDidSelectItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView didSelectItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView willDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewWillDeselectItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView willDeselectItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewDidDeselectItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView didDeselectItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView willDeselectAllItems:(NSArray *)theSelectedItems {
	[nc postNotificationName:CNGridViewWillDeselectAllItemsNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:theSelectedItems forKey:CNGridViewSelectedItemsKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView willDeselectAllItems:theSelectedItems];
	}
}

- (void)gridViewDidDeselectAllItems:(CNGridView *)gridView {
	[nc postNotificationName:CNGridViewDidDeselectAllItemsNotification object:gridView userInfo:nil];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridViewDidDeselectAllItems:gridView];
	}
}

- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewDidClickItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView didClickItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewDidDoubleClickItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:@(index) forKey:CNGridViewItemIndexKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView didDoubleClickItemAtIndex:index inSection:section];
	}
}

- (void)gridView:(CNGridView *)gridView didActivateContextMenuWithIndexes:(NSIndexSet *)indexSet inSection:(NSUInteger)section {
	[nc postNotificationName:CNGridViewRightMouseButtonClickedOnItemNotification
	                  object:gridView
	                userInfo:[NSDictionary dictionaryWithObject:indexSet forKey:CNGridViewItemsIndexSetKey]];
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate gridView:gridView didActivateContextMenuWithIndexes:indexSet inSection:section];
	}
}

#pragma mark - CNGridView DataSource Calls

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
	if ([self.dataSource respondsToSelector:_cmd]) {
		return [self.dataSource gridView:gridView numberOfItemsInSection:section];
	}
	return NSNotFound;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
	if ([self.dataSource respondsToSelector:_cmd]) {
		return [self.dataSource gridView:gridView itemAtIndex:index inSection:section];
	}
	return nil;
}

- (NSUInteger)numberOfSectionsInGridView:(CNGridView *)gridView {
	if ([self.dataSource respondsToSelector:_cmd]) {
		return [self.dataSource numberOfSectionsInGridView:gridView];
	}
	return NSNotFound;
}

- (NSString *)gridView:(CNGridView *)gridView titleForHeaderInSection:(NSInteger)section {
	if ([self.dataSource respondsToSelector:_cmd]) {
		return [self.dataSource gridView:gridView titleForHeaderInSection:section];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForGridView:(CNGridView *)gridView {
	if ([self.dataSource respondsToSelector:_cmd]) {
		return [self.dataSource sectionIndexTitlesForGridView:gridView];
	}
	return nil;
}

@end




#pragma mark - CNSelectionFrameView

@implementation CNSelectionFrameView

- (void)drawRect:(NSRect)rect {
	NSRect dirtyRect = NSMakeRect(0.5, 0.5, floorf(NSWidth(self.bounds)) - 1, floorf(NSHeight(self.bounds)) - 1);
	NSBezierPath *selectionFrame = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:0 yRadius:0];

	[[[NSColor blackColor] colorWithAlphaComponent:0.15] setFill];
	[selectionFrame fill];

	[[NSColor whiteColor] set];
	[selectionFrame setLineWidth:1];
	[selectionFrame stroke];
}

- (BOOL)isFlipped {
	return YES;
}

@end
#pragma clang diagnostic pop
