//
//  TGHorizontalTableView.m
//  Telegram
//
//  Created by keepcoder on 22/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGHorizontalTableView.h"
#import "PXListView+Private.h"
@implementation TGHorizontalTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSRect)rectOfRow:(NSUInteger)row
{
    id <PXListViewDelegate> delegate = [self delegate];
    
    if([delegate conformsToProtocol:@protocol(PXListViewDelegate)])
    {
        CGFloat cellWidth = NSWidth([self contentViewRect]);
        if([self inLiveResize]&&![self usesLiveResize]) {
            cellWidth = _widthPriorToResize;
        }
        
        CGFloat rowHeight = [delegate listView:self heightOfRow:row];
        CGFloat rowWidth = [delegate listView:self widthOfRow:row];
        return NSMakeRect(_cellYOffsets[row], 0, rowWidth, rowHeight);
    }
    
    return NSZeroRect;
}

- (void)cacheCellLayout
{
    id <PXListViewDelegate> delegate = [self delegate];
    
    if([delegate conformsToProtocol:@protocol(PXListViewDelegate)])
    {
        CGFloat totalHeight = 0;
        
        free(_cellYOffsets);
        _cellYOffsets = (CGFloat*)malloc(sizeof(CGFloat)*_numberOfRows);
        
        for( NSUInteger i = 0; i < _numberOfRows; i++ )
        {
            _cellYOffsets[i] = totalHeight;
            CGFloat cellHeight = [delegate listView:self widthOfRow:i];
            
            totalHeight += cellHeight +[self cellSpacing];
        }
        
        _totalHeight = totalHeight;
        
        NSRect bounds = [self bounds];
        CGFloat documentHeight = _totalHeight>NSHeight(bounds)?_totalHeight: (NSHeight(bounds) -2);
        
        [[self documentView] setFrame:NSMakeRect(0.0f, 0.0f, documentHeight, NSHeight([self contentViewRect]))];
    }
}

- (void)layoutCells
{
    //Set the frames of the cells
    for(id cell in _cellsInViewHierarchy)
    {
        NSInteger row = [(PXListViewCell *)cell row];
        [cell setFrame:[self rectOfRow:row]];
        [cell layoutSubviews];
    }
    
    NSRect bounds = [self bounds];
    CGFloat documentHeight = _totalHeight>NSHeight(bounds)?_totalHeight:(NSHeight(bounds) -2);
    
    //Set the new height of the document view
    [[self documentView] setFrame:NSMakeRect(0.0f, 0.0f, documentHeight, NSHeight([self contentViewRect]))];
}


- (NSRect)contentViewRect
{
    NSRect frame = [self frame];
    NSSize frameSize = NSMakeSize(NSWidth(frame), NSHeight(frame));
    BOOL hasHorizontalScroller = NSWidth(frame) < _totalHeight;
    NSSize availableSize = [[self class] contentSizeForFrameSize:frameSize
                                           hasHorizontalScroller:hasHorizontalScroller
                                             hasVerticalScroller:NO
                                                      borderType:[self borderType]];
    
    return NSMakeRect(0.0f, 0.0f, availableSize.width, availableSize.height);
}


- (NSRange)extendedRange
{
    NSRect visibleRect = [[self contentView] documentVisibleRect];
    //extend to adjacent rows for offscreen preparation
    NSRect extendedRect = NSMakeRect( visibleRect.origin.x - NSWidth(visibleRect), visibleRect.origin.y,
                                     visibleRect.size.width * 3,  visibleRect.size.height);
    NSUInteger startRow = NSUIntegerMax;
    NSUInteger endRow = NSUIntegerMax;
    
    BOOL inRange = NO;
    for(NSUInteger i = 0; i < _numberOfRows; i++)
    {
        if(NSIntersectsRect([self rectOfRow:i], extendedRect))
        {
            if(startRow == NSUIntegerMax)
            {
                startRow = i;
                inRange = YES;
            }
        }
        else
        {
            if(inRange)
            {
                endRow = i;
                break;
            }
        }
    }
    
    if(endRow == NSUIntegerMax)
    {
        endRow = _numberOfRows; 
    }
    
    return NSMakeRange(startRow, endRow-startRow);
}

@end
