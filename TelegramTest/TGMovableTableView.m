//
//  TGMovableTableView.m
//  Telegram
//
//  Created by keepcoder on 26/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGMovableTableView.h"

@interface TGMovableHoleView : TMView

@end


@implementation TGMovableHoleView


@end

@interface TGMovableTableClipView : NSClipView

@end

@implementation TGMovableTableClipView

-(BOOL)isFlipped {
    return YES;
}

@end

@interface TGMovableTableView ()
@property (nonatomic,strong) id reorderItem;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) TMView *containerView;;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) TMRowItem *movableItem;
@property (nonatomic,strong) TMRowView *movableView;
@property (nonatomic,assign) NSUInteger movableIndex;

@property (nonatomic,assign) NSInteger prevHoleIndex;
@property (nonatomic,assign) NSInteger currentHoleIndex;
@end

@implementation TGMovableTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
  
    _items = [NSMutableArray array];
    _containerView = [[TMView alloc] initWithFrame:self.bounds];
    _containerView.isFlipped = YES;
    
    [self setHasVerticalScroller:YES];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.documentView = _containerView;
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrameSize:NSMakeSize(newSize.width, MAX(self.containerHeight,newSize.height))];
    
    [_containerView.subviews enumerateObjectsUsingBlock:^(TMRowView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TMRowItem *item = _items[idx];
        
        TMRowView *prevView = idx == 0 ? nil : _containerView.subviews[idx - 1];
        
        [obj setFrame:NSMakeRect(0, NSMaxY(prevView.frame), NSWidth(_containerView.frame), [_mdelegate rowHeight:idx item:item])];
        
    }];
}

-(NSUInteger)count {
    return _items.count;
}

- (void)enumerateAvailableRowViewsUsingBlock:(void (^)(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row))handler {
   
    [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        handler([self viewAtIndex:idx],obj,idx);
        
    }];
    
}

- (void)insertItem:(TMRowItem *)item atIndex:(NSInteger)index {
    [self insertItemAtIndex:index item:item tile:YES];
}

- (void)addItems:(NSArray *)items {
    
    NSUInteger insertIndex = _items.count;
    
    [items enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self insertItemAtIndex:insertIndex+idx item:obj tile:NO];
        
    }];
    
    [self setFrameSize:self.frame.size];
}

- (void)removeAllItems {
    [_items removeAllObjects];
    [_containerView removeAllSubviews];
    [self tile];
}

-(void)insertItemAtIndex:(NSUInteger)index item:(TMRowItem *)item {
    [self insertItemAtIndex:index item:item tile:YES];
}

-(void)insertItemAtIndex:(NSUInteger)index item:(TMRowItem *)item tile:(BOOL)tile {
    
    TMRowView *lastView = self.count > 0 ? _containerView.subviews[MAX(index-1,0)] : nil;
    
    [_items insertObject:item atIndex:index];
    
    int height = [_mdelegate rowHeight:index item:item];
    
    TMRowView *view = [_mdelegate viewForRow:index item:item];
    
    [view setRowItem:item];
    [view redrawRow];
    item.table = self;
    
    [view setFrameSize:NSMakeSize(NSWidth(_containerView.frame), height)];

    [view setFrameOrigin:NSMakePoint(0, NSMaxY(lastView.frame))];
    
    [_containerView addSubview:view positioned:NSWindowAbove relativeTo:lastView];
    
    [_containerView setFrameSize:NSMakeSize(NSWidth(_containerView.frame), self.containerHeight)];
   
    if(tile)
        [self tile];
}


- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
   TMRowView *removeView = [self viewAtIndex:index];
    
    BOOL reverse = (NSHeight(self.frame) != NSHeight(self.containerView.frame)) && (NSMaxY(self.documentVisibleRect) > NSHeight(self.containerView.frame) - NSHeight(removeView.frame));
    
    int reverseScrollDif = reverse ? NSHeight(removeView.frame) - (NSMaxY(self.documentVisibleRect) - (NSHeight(self.containerView.frame) - NSHeight(removeView.frame))) : 0;
    
    __block int yHeight = reverse ? self.containerHeight - NSHeight(removeView.frame) : 0;
    
    [self beginUpdates];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        
        [context setDuration:animated ? 0.2 : 0];
        
        [[removeView animator] setAlphaValue:0];
        
        [_items enumerateObjectsWithOptions:reverse ? NSEnumerationReverse : 0 usingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TMRowView *view = [self viewAtIndex:idx];
            
            if(view != removeView) {
                
                [[view animator] setFrameOrigin:NSMakePoint(NSMinX(view.frame),yHeight)];
                
                yHeight+= reverse ? - NSHeight(view.frame) : NSHeight(view.frame);
            }
            
        }];
        
    } completionHandler:^{
        [removeView removeFromSuperview];
        [_items removeObjectAtIndex:index];
        
        [self setFrameSize:self.frame.size];
        
        if(reverseScrollDif > 0 && reverseScrollDif != NSHeight(removeView.frame)) {
            [self.clipView scrollRectToVisible:NSMakeRect(0, self.documentVisibleRect.origin.y - reverseScrollDif, 1, 1) animated:NO];
        }
        
        
        [self tile];
        
        [self endUpdates];
        
    }];
    
}

-(int)containerHeight {
    __block int height = 0;
    
    [_containerView.subviews enumerateObjectsWithOptions:0 usingBlock:^(TMRowView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        height+=NSHeight(obj.frame);
        
    }];
    
    
    return height;
}

- (void)removeItems:(NSArray *)items animated:(BOOL)animated {
    
}
- (void)removeItemsInRange:(NSRange)range animated:(BOOL)animated {
    
}

- (void)startMoveItemAtIndex:(NSUInteger)index {
    
    if(_locked)
        return;
    
    if(index != NSNotFound) {
        
        _movableItem = _items[index];
        _movableIndex = index;
        _movableView = [self viewAtIndex:index];
        
       
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:[NSColor grayColor]];
        [dropShadow setShadowOffset:NSMakeSize(0, 0)];
        [dropShadow setShadowBlurRadius:10.0];
        
        [[_movableView animator] setShadow:dropShadow];
        
        [_movableView setDragInSuperView:YES];
        [_movableView setNeedsDisplay:YES];
    
        NSMutableArray *subviews = [_containerView.subviews mutableCopy];
        
        [subviews removeObject:_movableView];
        
        [subviews addObject:_movableView];
        

        _containerView.subviews = subviews;
        
        [_items removeObject:_movableItem];
        
        _prevHoleIndex = index-1;
        _currentHoleIndex = index;
        
    }
}


-(void)moveHoleAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex animated:(BOOL)animated {
    
    __block int yHeight = 0;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        
        [context setDuration:animated ? 0.2 : 0];
        
        [_items enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] options:0 usingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TMRowView *view = [self viewAtIndex:idx];
            
            if(idx == _currentHoleIndex) {
                yHeight+=NSHeight(_movableView.frame);
            }
            
            if(view != _movableView) {
                [[view animator] setFrameOrigin:NSMakePoint(NSMinX(view.frame), yHeight)];
            }
            
             yHeight+=NSHeight(view.frame);
            
            
            
        }];
        
        
    } completionHandler:^{
        
    }];
    
}



-(TMRowView *)viewAtIndex:(NSUInteger)index {
    return index >= _containerView.subviews.count ? nil : _containerView.subviews[index];
}

-(NSUInteger)indexOfObject:(TMRowItem *)item {
    return [_items indexOfObject:item];
}


-(void)beginUpdates {
    _locked = YES;
}


-(void)endUpdates {
    _locked = NO;
}



-(void)mouseUp:(NSEvent *)theEvent {
    if(_movableItem != nil && !_locked) {
       
        [self saveMovableItem];
        
    }
}

- (BOOL)itemIsMovable:(TMRowItem *)item {
    return _movableItem == item;
}


-(void)saveMovableItem {
    
    [self beginUpdates];
    
    [_movableView setDragInSuperView:NO];
    
    [_movableView setNeedsDisplay:YES];
    
    int y = [self yOfIndex:_currentHoleIndex-1];

    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        
        [[_movableView animator] setFrameOrigin:NSMakePoint(0, y)];
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:[NSColor whiteColor]];
        [dropShadow setShadowOffset:NSMakeSize(0, 0)];
        [dropShadow setShadowBlurRadius:0];
        [[_movableView animator] setShadow:dropShadow];
        
        
    } completionHandler:^{
        
        
        
        [_movableView setShadow:nil];
        
        [_items insertObject:_movableItem atIndex:_currentHoleIndex];
        NSMutableArray *subviews = [_containerView.subviews mutableCopy];
        
        [subviews removeObject:_movableView];
        
        [subviews insertObject:_movableView atIndex:_currentHoleIndex];
        
        _containerView.subviews = subviews;
        
        
        if(_movableIndex != _currentHoleIndex && [_mdelegate respondsToSelector:@selector(tableViewDidChangeOrder)]) {
            [_mdelegate tableViewDidChangeOrder];
        }
        
        _movableItem = nil;
        _movableIndex = 0;
        _movableView = nil;
        
        
        
        _movableIndex = NSNotFound;
        _currentHoleIndex = 0;
        _prevHoleIndex = 0;
        
        
        
        
        [self endUpdates];
    }];
    
}

-(int)yOfIndex:(NSInteger)index {
    
    __block int y = 0;
    
    if(index == 0)
        return [_mdelegate rowHeight:0 item:_items[0]];
     else if(index == -1)
        return 0;
    
   [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
       y+=[_mdelegate rowHeight:index item:obj];
      
       if(index <= idx) {
           *stop = YES;
       }
       
   }];
   
    return y;
}

-(void)mouseDragged:(NSEvent *)theEvent {
  
    if(_movableItem != nil && !_locked) {
        [self updateMovableItem:[_containerView convertPoint:[theEvent locationInWindow] fromView:nil]];
    }

}


-(void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    
    if(_movableItem != nil && !_locked) {
        
        [_movableView mouseDragged:theEvent];
        
        [self updateMovableItem:[_containerView convertPoint:[theEvent locationInWindow] fromView:nil]];
    }
}

-(NSRange)rangeOfRect:(NSRect)rect {
    
    __block int currentY = 0;
    
    __block NSRange range = NSMakeRange(NSNotFound, 0);
   
    [_containerView.subviews enumerateObjectsUsingBlock:^(TMRowView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int prevY = currentY;
        
        currentY += NSHeight(obj.frame);
        
        if((prevY <= NSMinY(rect) && currentY >= NSMaxY(rect)) ) {
            
            if(range.location == NSNotFound)
                range.location = idx;
            
            range.length++;
            
        }

        
    }];
    
    return range;
    
}

-(void)updateMovableItem:(NSPoint)point {
    
    
    NSRange range = [self rangeOfRect:NSMakeRect(0, point.y, 0, 1)];
    

    if(range.location != NSNotFound) {
       
        _prevHoleIndex = _currentHoleIndex;
        _currentHoleIndex = range.location;
        
        [self moveHoleAtIndex:_prevHoleIndex toIndex:_currentHoleIndex animated:YES];
        
    }
    
}

@end
