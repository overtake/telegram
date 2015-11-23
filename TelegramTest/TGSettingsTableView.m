//
//  TGSettingsTableView.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSettingsTableView.h"
#import "TGGeneralRowItem.h"

@interface TGSettingsTableView () <TMTableViewDelegate>

@end

@implementation TGSettingsTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)setFrameSize:(NSSize)newSize {
   
    
    
    if([self inLiveResize]) {
        NSRange visibleRows = [self rowsInRect:self.scrollView.contentView.bounds];
        if(visibleRows.length > 0) {
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSInteger count = visibleRows.location + visibleRows.length;
            for(NSInteger i = visibleRows.location; i < count; i++) {
               
                TGGeneralRowItem *item = (TGGeneralRowItem *)[self itemAtPosition:i];
                
                if([item updateItemHeightWithWidth:newSize.width]) {
                    id view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
                    //  if([view isKindOfClass:[MessageTableCellTextView class]]) {
                    if(view)
                        [array addObject:view];
                    //  }
                }
            }
            
            [self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:visibleRows]];
            
            for(TGGeneralRowItem *cell in array) {
                [cell redrawRow];
            }
            
            [NSAnimationContext endGrouping];
        }
        
    } else {
        [self fixedResizeWithWidth:newSize.width];
    }
    
     [super setFrameSize:newSize];
}



- (void)fixedResizeWithWidth:(int)width {
    
    
    [self.list enumerateObjectsUsingBlock:^(TGGeneralRowItem  *item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item updateItemHeightWithWidth:width];
    }];

}
- (void)viewDidEndLiveResize {
    
    [self.list enumerateObjectsUsingBlock:^(TGGeneralRowItem  *item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item updateItemHeightWithWidth:NSWidth(self.frame)];
    }];
    
    [self reloadData];
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.tm_delegate = self;
    }
    
    return self;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TGGeneralRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

-(BOOL)addItem:(TGGeneralRowItem *)item tableRedraw:(BOOL)tableRedraw {
    [item updateItemHeightWithWidth:NSWidth(self.frame)];
    return [super addItem:item tableRedraw:tableRedraw];
}

-(BOOL)insert:(NSArray *)array startIndex:(NSUInteger)startIndex tableRedraw:(BOOL)tableRedraw {
    [array enumerateObjectsUsingBlock:^(TGGeneralRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateItemHeightWithWidth:NSWidth(self.frame)];
    }];
    return [super insert:array startIndex:startIndex tableRedraw:tableRedraw];
}

-(BOOL)insert:(TGGeneralRowItem *)item atIndex:(NSUInteger)atIndex tableRedraw:(BOOL)tableRedraw {
    [item updateItemHeightWithWidth:NSWidth(self.frame)];
    return [super insert:item atIndex:atIndex tableRedraw:tableRedraw];
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TGGeneralRowItem *) item {
   return [self cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(self.frame), [item height])];
}

- (void)selectionDidChange:(NSInteger)row item:(TGGeneralRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

@end
