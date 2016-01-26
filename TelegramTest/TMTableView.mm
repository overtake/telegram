//
//  TMTableView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#include <map>
#include <set>

@interface TMTableView()
@property (nonatomic) NSUInteger listSelectedElementHash;
@property (nonatomic) std::map<NSUInteger, id> *listCacheHash;
@property (nonatomic) std::set<NSUInteger> *listSelectionHash;


@property (nonatomic) BOOL mouseOverView;
@property (nonatomic) NSInteger mouseOverRow;
@property (nonatomic) NSInteger lastOverRow;
@property (nonatomic, strong)  NSTrackingArea *trackingArea;



@end

@implementation TMTableView


static TMTableView *tableStatic;

+ (TMTableView *)current {
    if(!tableStatic.isHidden)
        return tableStatic;
    else
        return nil;
}

+ (void)setCurrent:(TMTableView *)table {
    tableStatic = table;
}

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self initialize];
    }
    return self;
}



// Code


- (void)initialize {
    [self setHeaderView:nil];
    
    self.defaultAnimation = NSTableViewAnimationEffectNone;
    
    _scrollView = [[TMScrollView alloc] initWithFrame:self.frame];
    
    //[self setFrame:self.bounds];
    
   
    
    self.scrollView.documentView = self;
    
    
    
   
    
    self.scrollView.hasVerticalScroller = YES;
    [self.scrollView setAutoresizesSubviews:YES];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    _tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"colum1"];
    self.tableColumn.width = self.bounds.size.width;
    [self addTableColumn:self.tableColumn];
    
    
    [self setIntercellSpacing:NSMakeSize(0, 0)];
    
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    
    self.delegate = self;
    self.dataSource = self;
    
    _list = [[NSMutableArray alloc] init];
    self.listCacheHash = new std::map<NSUInteger, id>();
    self.listSelectionHash = new std::set<NSUInteger>();
    
    self.listSelectedElementHash = NSNotFound;
    self.multipleSelection = NO;
    
    [self setFloatsGroupRows:YES];
    [self setFloatValue:0];
    
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    
    self.mouseOverView = NO;
    self.mouseOverRow = -1;
    self.lastOverRow = -1;
    
    [self updateTrackingAreas];
    
    
    
    id document = self.scrollView.documentView;
    BTRClipView *clipView = [[BTRClipView alloc] initWithFrame:self.scrollView.contentView.bounds];
    [clipView setWantsLayer:YES];
    [clipView setDrawsBackground:YES];
    [self.scrollView setContentView:clipView];
    self.scrollView.documentView = document;
    
}

- (void)setHoverCells:(BOOL)hoverCells {
    self->_hoverCells = hoverCells;
    
    if(hoverCells) {
        [self updateTrackingAreas];
    } else {
        [self removeTrackingArea:self.trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseMoved:theEvent];
    
    self.mouseOverView = YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    
	self.mouseOverView = NO;
    [self setHover:NO forRow:self.mouseOverRow];
	self.mouseOverRow = -1;
	self.lastOverRow = -1;
}


- (void)setHover:(BOOL)hover forRow:(NSInteger)row {
    if(row  < 0 || row >= self.count)
        return;
    
    TMRowView *view = [self viewAtColumn:0 row:self.lastOverRow makeIfNecessary:NO];
    if(view) {
        if([view respondsToSelector:@selector(setHover:redraw:)]) {
            [view setHover:hover redraw:YES];
        }
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if(!self.hoverCells)
        return;
    
    [self removeTrackingArea:self.trackingArea];
    
    static const NSUInteger options = (NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseMoved);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:options
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

-(void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
    
    [self updateTrackingAreas];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self updateTrackingAreas];
}

- (void)checkHover {
    if (self.mouseOverView) {
        self.mouseOverRow = [self rowAtPoint:[self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil]];
		
		if (self.lastOverRow == self.mouseOverRow)
			return;
		else {
            [self setHover:NO forRow:self.lastOverRow];
			self.lastOverRow = self.mouseOverRow;
		}
        
        [self setHover:YES forRow:self.lastOverRow];
	}
}

- (void)mouseMoved:(NSEvent*)theEvent
{
    [super mouseMoved:theEvent];
	id myDelegate = [self delegate];
    
	if (!myDelegate)
		return;
	[self checkHover];
}

- (NSObject *) isItemInList:(NSObject*)item {
    NSUInteger hash = [item hash];
    return [self itemByHash:hash];
}

- (NSObject *)selectedItem {
    if(self.listSelectedElementHash != NSNotFound)
        return [self itemByHash:self.listSelectedElementHash];
    return nil;
}

- (NSObject *) itemByHash:(NSUInteger)hash {
    std::map<NSUInteger, id>::iterator it = self.listCacheHash->find(hash);
    if(it != self.listCacheHash->end())
        return it->second;
    return nil;
}

- (NSUInteger) positionOfItem:(NSObject*)item {
    return [self.list indexOfObject:item];
}

- (BOOL) insert:(NSArray* )array
     startIndex:(NSUInteger)startIndex
    tableRedraw:(BOOL)tableRedraw {
    
    assert([NSThread currentThread] == [NSThread mainThread]);
    
    int count = 0;
    for(NSObject* object in array) {
        if([self insert:object atIndex:startIndex + count tableRedraw:NO]) {
            count++;
        } else {
          //  MTLog(@"ne");
        }
    }
    
    if(count && tableRedraw) {
        [self beginUpdates];
        [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, count)] withAnimation:self.defaultAnimation];
        [self endUpdates];
    }
    return YES;
}

- (BOOL) addItem:(NSObject *)item
       tableRedraw:(BOOL)tableRedraw {
    return [self insert:item atIndex:self.list.count tableRedraw:tableRedraw];
}

- (BOOL) insert:(NSObject *)item
        atIndex:(NSUInteger)atIndex
    tableRedraw:(BOOL)tableRedraw {
    
    if([self isItemInList:item] != nil)
        return NO;
    
    self.listCacheHash->insert(std::pair<NSUInteger, id>([item hash], item));
    [self.list insertObject:item atIndex:atIndex];
    TMRowItem *rowItem = (TMRowItem *)(item);
    rowItem.table = self;
    
    if(tableRedraw) {
        [self beginUpdates];
        [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:atIndex] withAnimation:self.defaultAnimation];
        [self endUpdates];
    }
    return YES;
}

- (NSUInteger) count {
    return self.list.count;
}

- (void) moveItemFrom:(NSUInteger)from
                     to:(NSUInteger)to
            tableRedraw:(BOOL)tableRedraw {
    
    if(from == to)
        return;
    
    if(to > self.list.count-1) // fix move item, for all tables
        to = self.list.count-1; //
    
    NSObject *item = [self.list objectAtIndex:from];
    [self.list removeObjectAtIndex:from];
    [self.list insertObject:item atIndex:to];
    
    if(tableRedraw){
        [self beginUpdates];
        [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:from] withAnimation:_defaultAnimation];
        [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:to] withAnimation:_defaultAnimation];
        [self endUpdates];
      //  [self moveRowAtIndex:from toIndex:to];
    }
    
}

- (NSObject *) itemAtPosition:(NSUInteger)positionOfItem {
    return [self.list objectAtIndex:positionOfItem];
}

- (NSUInteger)indexOfItem:(NSObject *)item {
    return [self.list indexOfObject:item];
}

- (BOOL)removeItem:(TMRowItem *)item {
    return [self removeItem:item tableRedraw:YES];
}


- (BOOL)removeItem:(TMRowItem *)item  tableRedraw:(BOOL)tableRedraw {
    TMRowItem *itemInList = (TMRowItem *)[self itemByHash:item.hash];
    if(itemInList) {
        NSUInteger pos = [self positionOfItem:itemInList];
        if(pos != NSNotFound) {
            self.listCacheHash->erase(itemInList.hash);
            [self.list removeObjectAtIndex:pos];
            itemInList.table = nil;
            
            if(tableRedraw) {
                [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:pos] withAnimation:self.defaultAnimation];
            }
            
        }
    }
    return NO;
}


- (BOOL)removeAllItems:(BOOL)tableRedraw {
    NSUInteger count = self.list.count;
    self.listCacheHash->clear();
    [self.list removeAllObjects];
    
    if(tableRedraw) {
        [self cancelSelection];
        
        [self beginUpdates];
        [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)] withAnimation:self.defaultAnimation];
        [self endUpdates];
    }
    
    return YES;
}

- (void) removeItemsInRange:(NSRange)range tableRedraw:(BOOL)tableRedraw {
    
    NSArray *copy = [_list copy];
    
    [copy enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeItem:obj tableRedraw:NO];
    }];
    
    if(tableRedraw) {
         [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:self.defaultAnimation];
    }
}


- (void)redrawAll {
    for (TMRowItem *item in self.list) {
        [item redrawRow];
    }
}

- (void) keyDown:(NSEvent *)theEvent {
    
    if(theEvent.keyCode == 125 || theEvent.keyCode == 126 || theEvent.keyCode == 121 || theEvent.keyCode == 116) {
        
        if([NSClassFromString(@"TMViewController") performSelector:@selector(isModalActive) withObject:nil])
            return;
        
        NSUInteger pos = 0;
        id item = [self itemByHash:self.listSelectedElementHash];
        if(item) {
            pos = [self positionOfItem:item];
            if(pos == NSNotFound) {
                pos = 0;
            }
            
            
            if(theEvent.keyCode == 125 || theEvent.keyCode == 121) {
                pos++;
            } else {
                pos--;
            }
        }
        
        while(true) {
            if(self.count > pos && pos < NSNotFound) {
                if([self.tm_delegate isSelectable:pos item:[self.list objectAtIndex:pos]]) {
                    break;
                }
            } else {
                break;
            }
            
            if(theEvent.keyCode == 125 || theEvent.keyCode == 121) {
                pos++;
            } else {
                pos--;
            }
        }

        
        if(self.count > pos && pos < NSNotFound) {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:pos] byExtendingSelection:NO];
            
            int posS = (int)(pos + (theEvent.keyCode == 125 || theEvent.keyCode == 121 ? 1 : -1));
            int count = (int)self.count - 1;
            
            int rowIndex = MAX(0, MIN(posS, count));
            
            [self scrollRowToVisible:rowIndex];
        }
    }
}

- (BOOL) setSelectedByHash:(NSUInteger)hash {
    NSObject *item = [self itemByHash:hash];
    if(item) {
        return [self setSelectedObject:item];
    }
    return NO;
}

- (BOOL) setSelectedObject:(NSObject *)item {
    NSObject *itemInList = [self isItemInList:item];
    if(!itemInList)
        return NO;
    
    NSUInteger pos = [self positionOfItem:item];
    if(pos == NSNotFound)
        return NO;
    
    if(![self.tm_delegate isSelectable:pos item:(TMRowItem *)itemInList])
        return NO;
    
    if(self.multipleSelection) {
        
    } else {
        if(itemInList) {
            [self cancelSelection];
            self.listSelectedElementHash = [itemInList hash];
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:pos] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            return YES;
        }
    }
    return NO;
}

- (void) cancelSelection:(NSObject*)object {
    if(object) {
        NSUInteger pos = [self positionOfItem:object];
        self.listSelectedElementHash = NSNotFound;
        if(pos != NSNotFound) {
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:pos] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    [self selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
}

- (void) cancelSelection {
    if(self.multipleSelection) {
//        [self cancelSelection:<#(NSObject *)#>]
    } else {
        if(self.listSelectedElementHash != NSNotFound)
            [self cancelSelection:[self itemByHash:self.listSelectedElementHash]];
    }
}

- (void)dealloc {
    if(self.listCacheHash)
        self.listCacheHash->clear();
    if(self.listSelectionHash)
        self.listSelectionHash->clear();
    delete self.listCacheHash;
    delete self.listSelectionHash;
    
    [self removeTrackingArea:self.trackingArea];
}

- (NSScrollView*)containerView {
    return self.scrollView;
}

- (TMRowView *) cacheViewForClass:(Class)classObject
                       identifier:(NSString *)identifier {
    return [self cacheViewForClass:classObject identifier:identifier withSize:NSZeroSize];
}

- (TMRowView *) cacheViewForClass:(Class)classObject
                       identifier:(NSString *)identifier
                         withSize:(NSSize)size {
    TMRowView *cell = [self makeViewWithIdentifier:identifier owner:self];
    if (cell == nil) {
        cell = [[classObject alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)];
        cell.identifier = identifier;
    }
    return cell;
}

//Table

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.list.count;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    if(self.selectedRow == NSNotFound || self.selectedRow == -1)
        return;
    
    NSObject *itemList = [self.list objectAtIndex:self.selectedRow];
    
    BOOL result = [self.tm_delegate selectionWillChange:self.selectedRow item:(TMRowItem *)itemList];
    if(result) {
        if([self setSelectedObject:itemList]) {
            [self.tm_delegate selectionDidChange:self.selectedRow item:(TMRowItem *)itemList];
        }
    }
    [self selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
}

- (CGFloat)tableView:(NSTableView *)tableView
         heightOfRow:(NSInteger)row {
    return [self.tm_delegate rowHeight:row item:[self.list objectAtIndex:row]];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    if(self.list.count > row)
        return [self.tm_delegate respondsToSelector:@selector(isGroupRow:item:)] && [self.tm_delegate isGroupRow:row item:[self.list objectAtIndex:row]];
    return NO;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    TMRowItem *item = [self.list objectAtIndex:row];
    
    TMRowView *cell = [self.tm_delegate viewForRow:row item:item];
    [cell setRow:row];
    [cell setHover:row == self.mouseOverRow redraw:NO];
    [cell setItem:item selected:item.hash == self.listSelectedElementHash ? YES : NO];
    [item setTable:self];
    
    return cell;
}


- (void)insertNewline:(id)sender {
    // Enter key. Do special stuff here...
}

- (void)reloadData {
    self.containerView.wantsLayer = NO;
    [super reloadData];
    self.containerView.wantsLayer = YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    
    [super mouseDown:theEvent];
    
    [TMTableView setCurrent:self];
    
    if([self.className isEqualToString:@"TGConversationsTableView"] && !self.isHidden )
         [self.scrollView mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    
    if(![self.className isEqualToString:@"MessagesTableView"])
        [super mouseDragged:theEvent];
    
    if([self.className isEqualToString:@"TGConversationsTableView"] && !self.isHidden)
        [self.scrollView mouseDragged:theEvent];
}

-(BOOL)rowIsVisible:(NSUInteger)index {
    NSRange range = [self rowsInRect:[self visibleRect]];
    
    return range.location <= index && range.location + range.length >= index;
}

@end
