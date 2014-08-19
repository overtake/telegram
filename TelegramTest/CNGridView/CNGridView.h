//
//  CNGridView.h
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
#import "CNGridViewDefinitions.h"
#import "CNGridViewDelegate.h"
#import "CNGridViewItem.h"

typedef BOOL (^CNGridViewSelectItem)(CNGridViewItem *item);

/**
 `CNGridView` is a (wanna be) replacement for NSCollectionView. It has full delegate and dataSource support with method calls like known from NSTableView/UITableView.

 The use of `CNGridView` is just simple as possible.
 */


@interface CNGridView : NSView

#pragma mark - Initializing a CNGridView Object
/** @name Initializing a CNGridView Object */


#pragma mark - Managing the Delegate and the Data Source
/** @name Managing the Delegate and the Data Source */

/**
 Property for the receiver's delegate.
 */
@property (nonatomic, assign) IBOutlet id<CNGridViewDelegate> delegate;

/**
 Property for the receiver's data source.
 */
@property (nonatomic, assign) IBOutlet id<CNGridViewDataSource> dataSource;



#pragma mark - Configuring the GridView
/** @name Configuring the GridView */

/**
 Property for a title of the grid view.

 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *gridViewTitle;

/**
 Property for the background color of the grid view.

 This color (or pattern image) will be assigned to the enclosing scroll view. In the phase of initializing `CNGridView` will
 send the enclosing scroll view a `setDrawsBackground` message with `YES` as parameter value. So it's guaranteed the background
 will be drawn even if you forgot to set this flag in interface builder.

 If you don't use this property, the default value is `[NSColor controlColor]`.
 */
@property (nonatomic, strong) NSColor *backgroundColor;

/**
 Property for setting the elasticity of the enclosing `NSScrollView`.

 This property will set and overwrite the values from Interface Builder. There is no horizontal-vertical distinction.
 The default value is `YES`.

 @param     YES Elasticity is on.
 @param     NO Elasticity is off.

 */
@property (nonatomic, assign) BOOL scrollElasticity;

/**
 Property for setting the grid view item size.

 You can set this property programmatically to any value you want. On each change of this value `CNGridView` will automatically
 refresh the entire visible grid view with an animation effect.
 */
@property (nonatomic, assign) NSSize itemSize;



#pragma mark - Creating GridView Items
/** @name Creating GridView Items */

/**
 Returns a reusable grid view item object located by its identifier.

 @param identifier  A string identifying the grid view item object to be reused. This parameter must not be nil.
 @return A CNGridViewItem object with the associated identifier or nil if no such object exists in the reusable queue.
 */
- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier;



#pragma mark - Managing the Content
/** @name  Managing the Content */

/**
 Returns the number of currently visible items of `CNGridView`.

 The returned value of this method is subject to continous variation. It depends on the actual size of its view and will be calculated in realtime.
 */
- (NSUInteger)numberOfVisibleItems;



#pragma mark - Managing Selections and Hovering
/** @name Managing Selections */

/**
 Property for setting whether the grid view allows item selection or not.

 The default value is `YES`.
 */
@property (nonatomic, assign) BOOL allowsSelection;

/**
 Property that indicates whether the grid view should allow multiple item selection or not.

 If you have this property set to `YES` with actually many selected items, all these items will be unselect on setting `allowsMultipleSelection` to `NO`.

 @param YES The grid view allows multiple item selection.
 @param NO  The grid view don't allow multiple item selection.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 Property indicates if the mouse drag operation can be used to select multiple items.

 If you have this property set to `YES` you must also set `allowsMultipleSelection`

 @param YES The grid view allows multiple item selection with mouse drag.
 @param NO  The grid view don't allow multiple item selection with mouse drag.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelectionWithDrag;

/**
 ...
 */
@property (nonatomic, assign) BOOL useSelectionRing;

/**
 ...
 */
@property (nonatomic, assign) BOOL useHover;

/**
 `NSMenu` to use when an item or the selected items are right clicked
 */
@property (nonatomic, assign) IBOutlet NSMenu *itemContextMenu;

/**
 Selects all the items in the grid
 */
- (void)selectAllItems;

/**
 Deselects all the selected items in the grid
 */
- (void)deselectAllItems;

/**
 Selects the specified item
 */
- (void)selectItem:(CNGridViewItem *)theItem;

/**
 Selects all the items in the grid and passes each item to the specified block
 */
- (void)selectItemsWithBlock:(CNGridViewSelectItem)blockSelector;

/**
 Removes selection for the specified item
 */
- (void)deSelectItem:(CNGridViewItem *)theItem;

/**
 Returns an array of the selected `CNGridViewSelectItem` items.
 */
- (NSArray *)selectedItems;

/**
 Returns an index set of the selected items
 */
- (NSIndexSet*)selectedIndexes;

/**
 Indexes of all the visible items
 */
- (NSIndexSet*)visibleIndexes;

#pragma mark - Reloading GridView Data
/** @name  Reloading GridView Data */

/**
 Reloads all the items on the grid from the data source
 */
- (void)reloadData;

- (void)reloadDataAnimated:(BOOL)animated;

#pragma mark - animating KVO changes

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertItemsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)reloadItemsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)removeItemsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)beginUpdates;
- (void)endUpdates;

@property(nonatomic,strong) IBOutlet NSView* headerView;
@property(nonatomic,assign) BOOL useCenterAlignment;

- (NSRect)rectForItemAtIndex:(NSUInteger)index;

@end
