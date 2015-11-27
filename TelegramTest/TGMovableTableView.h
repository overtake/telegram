//
//  TGMovableTableView.h
//  Telegram
//
//  Created by keepcoder on 26/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"

@protocol TGMovableTableDelegate <NSObject>

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item;
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item;
- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item;
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item;
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item;

@optional
- (void)tableViewDidChangeOrder;

@end

@interface TGMovableTableView : BTRScrollView

@property (nonatomic,weak) id <TGMovableTableDelegate> mdelegate;

-(NSUInteger)count;


- (void)insertItem:(TMRowItem *)item atIndex:(NSInteger)index;
- (void)addItems:(NSArray *)items;
- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeItems:(NSArray *)items animated:(BOOL)animated;
- (void)removeItemsInRange:(NSRange)range animated:(BOOL)animated;
- (void)startMoveItemAtIndex:(NSUInteger)index;

- (BOOL)itemIsMovable:(TMRowItem *)item;

- (void)enumerateAvailableRowViewsUsingBlock:(void (^)(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row))handler;

- (void)removeAllItems;
-(NSUInteger)indexOfObject:(TMRowItem *)item;
@end
