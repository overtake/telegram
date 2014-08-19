//
//  TMTableView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMRowItem.h"
#import "TMRowView.h"
#import "TMScrollView.h"

@protocol TMTableViewDelegate <NSObject>

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item;
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item;
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item;
- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item;
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item;
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item;

@end



@interface TMTableView : NSTableView<NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) TMScrollView *scrollView;
@property (nonatomic, strong) NSTableColumn *tableColumn;
@property (nonatomic) BOOL multipleSelection;
@property (nonatomic, strong) id<TMTableViewDelegate> tm_delegate;
@property (nonatomic) BOOL hoverCells;
@property (nonatomic) NSTableViewAnimationOptions defaultAnimation;


+ (TMTableView *)current;
+ (void)setCurrent:(TMTableView *)table;

- (void)checkHover;

- (TMRowView *) cacheViewForClass:(Class)classObject
                       identifier:(NSString *)identifier;

- (TMRowView *) cacheViewForClass:(Class)classObject
                       identifier:(NSString *)identifier
                         withSize:(NSSize)size;

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (NSScrollView *)containerView;

- (NSUInteger) positionOfItem:(NSObject *)item;

- (NSObject *) isItemInList:(NSObject *)item;

- (BOOL) addItem:(NSObject *)item
       tableRedraw:(BOOL)tableRedraw;

- (BOOL) insert:(NSArray *)array
     startIndex:(NSUInteger)startIndex
    tableRedraw:(BOOL)tableRedraw;

- (BOOL) insert:(NSObject *)item
        atIndex:(NSUInteger)atIndex
    tableRedraw:(BOOL)tableRedraw;

- (void) moveItemFrom:(NSUInteger)from
                     to:(NSUInteger)to
            tableRedraw:(BOOL)tableRedraw;

- (NSObject *) itemByHash:(NSUInteger)hash;
- (NSObject *) itemAtPosition:(NSUInteger)positionOfItem;
- (NSUInteger)indexOfItem:(NSObject *)item;
- (NSObject *)selectedItem;
- (BOOL) setSelectedByHash:(NSUInteger)hash;
- (void) cancelSelection;
- (void) cancelSelection:(NSObject*)object;

- (BOOL) removeItem:(TMRowItem *)item;
- (BOOL) removeAllItems:(BOOL)tableRedraw;
- (void) redrawAll;
- (NSUInteger) count;

@end
