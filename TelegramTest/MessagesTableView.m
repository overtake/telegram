//
//  MessagesTableView.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/30/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MessagesTableView.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessageSender.h"
#import "Telegram.h"
#import "MessageTableCellTextView.h"
#import "HackUtils.h"
#import "DraggingControllerView.h"
#import "FileUtils.h"
#import "MessageTableCellContainerView.h"
#import "MessageTableHeaderItem.h"






@interface MessagesTableView() <TMScrollViewDelegate, SelectTextManagerDelegate>
@property (nonatomic) NSSize oldSize;
@property (nonatomic) NSSize oldFixedSize;
@property (nonatomic) NSSize oldOldSize;

@property (nonatomic) BOOL isLocked;


@property (nonatomic,strong) MessageTableItemText *firstSelectItem;
@property (nonatomic,strong) MessageTableItemText *currentSelectItem;

@property (nonatomic,assign) NSPoint startSelectPosition; // not converted

@end




@implementation MessagesTableView

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.wantsLayer = YES;
//        self.layer = [[TMLayer alloc] initWithLayer:self.layer];
        
        [Notification addObserver:self selector:@selector(notificationFullScreen) name:NSWindowDidEnterFullScreenNotification];
        [Notification addObserver:self selector:@selector(notificationFullScreen) name:NSWindowDidExitFullScreenNotification];
        
        self.scrollView.delegate = self;
        
        _startSelectPosition = NSMakePoint(INT32_MIN, INT32_MIN);
        
        [SelectTextManager addSelectManagerDelegate:self];
    }
    return self;
}

-(void)scrollDidChangeFrameSize:(NSSize)size {
 //   [self.viewController updateHeaderHeight:[self inLiveResize] animated:NO];

}




-(BOOL)isFlipped {
    return NO;
}

- (void)notificationFullScreen {
    DLog(@"log");
    [self reloadData];
}

- (NSObject *)itemByPosition:(NSUInteger)position {
    return [self.viewController objectAtIndex:position];
}

- (NSSize)containerSize {
    return NSMakeSize(self.bounds.size.width - 150, 0);
}


- (void)tile {
    [super tile];
}

-(void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
}


- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    self.oldOldSize = self.oldSize;
    

    
//    return;
    if(self.oldSize.width == self.frame.size.width)
        return;
    
    self.oldSize = self.frame.size;
    
    if([self inLiveResize]) {
        NSRange visibleRows = [self rowsInRect:self.scrollView.contentView.bounds];
        if(visibleRows.length > 0) {
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSInteger count = visibleRows.location + visibleRows.length;
            for(NSInteger i = visibleRows.location; i < count; i++) {
                MessageTableItem *item = (MessageTableItem *)[self itemByPosition:i];
                
                if([item makeSizeByWidth:self.containerSize.width]) {
                    id view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
                    if([view isKindOfClass:[MessageTableCellTextView class]]) {
                        [array addObject:view];
                    }
                }
            }
            
            [self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:visibleRows]];
            
            for(MessageTableCell *cell in array) {
                [cell resizeAndRedraw];
            }
            
            [NSAnimationContext endGrouping];
        }
        
        
       
        
    } else {
        [self fixedResize];
    }
}

- (void)fixedResize {
    if(self.isLocked)
        return;
    
    
    if(self.oldFixedSize.width == self.frame.size.width)
        return;
    
    self.oldFixedSize = self.frame.size;
    
    self.isLocked = YES;

    for(NSUInteger i = 0; i < self.viewController.messagesCount; i++) {
        MessageTableItem *item = (MessageTableItem *)[self itemByPosition:i];
        [item makeSizeByWidth:self.containerSize.width];
    }
    
    [self reloadData];
    
    
    self.isLocked = NO;
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint tablePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSUInteger row = [self rowAtPoint:tablePoint ];
    
    if(row == NSUIntegerMax && tablePoint.y > 0 && NSHeight(self.frame) == NSHeight(self.scrollView.frame)) {
        row = [self.viewController messagesCount] - 1;
    }
    
    self.firstSelectItem = [self.viewController messageList][row];
    
    
    [SelectTextManager clear];
    [SelectTextManager becomeFirstResponder];
    
    _startSelectPosition = tablePoint;
    
    
}


- (void)clearSelection {
    
    [self enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        
        MessageTableCellContainerView *container = [rowView subviews][0];
        
        if([container isKindOfClass:[MessageTableCellTextView class]]) {
            [((MessageTableCellTextView *)container).textView setSelectionRange:NSMakeRange(NSNotFound, 0)];
        }
        
    }];
}

-(NSUInteger)indexOfItem:(NSObject *)item {
    return [[self.viewController messageList] indexOfObject:item];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    if(_startSelectPosition.x == INT32_MIN && _startSelectPosition.y == INT32_MIN)
        return;
    
    [SelectTextManager clear];
    [SelectTextManager becomeFirstResponder];
    
    NSPoint point = [theEvent locationInWindow]; // not converted
    
    NSPoint tablePoint = [self convertPoint:point fromView:nil];
    
    if(tablePoint.x < 0) {
        tablePoint.x = 0;
    }
    if(tablePoint.x > NSWidth(self.frame)) {
        tablePoint.x = NSWidth(self.frame) - 1;
    }
    if(tablePoint.y < 0) {
        tablePoint.y = 0;
    }
    if(tablePoint.y > NSHeight(self.frame)) {
        tablePoint.y = NSHeight(self.frame) - 1;
    }
    
    NSUInteger row = [self rowAtPoint:tablePoint];
    
    if(row == NSUIntegerMax && tablePoint.y > 0 && NSHeight(self.frame) == NSHeight(self.scrollView.frame)) {
        row = [self.viewController messagesCount] - 1;
    }
    
    self.currentSelectItem = [self.viewController messageList][row];
    
    NSUInteger startRow = [self indexOfItem:self.firstSelectItem];
    
    NSUInteger endRow = [self indexOfItem:self.currentSelectItem];
    
    
    BOOL reversed = endRow < startRow;
    
    if(endRow < startRow) {
        startRow = startRow + endRow;
        endRow = startRow - endRow;
        startRow = startRow - endRow;
    }
    
    BOOL isMultiple = abs((int)endRow - (int)startRow) > 0;
    
    for (NSUInteger i = startRow; i <= endRow; i++) {
        
         id view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
        
        if([view isKindOfClass:[MessageTableCellTextView class]]) {
            
            TGMultipleSelectTextView *textView = ((MessageTableCellTextView *)view).textView;
            
            MessageTableItem *item = self.viewController.messageList[i];
            
            
            NSPoint startConverted = [textView convertPoint:_startSelectPosition fromView:self];
            NSPoint currentConverted = [textView convertPoint:point fromView:nil];
            
            
            if(i > startRow && i < endRow) {
                
                textView->startSelectPosition = NSMakePoint(NSWidth(textView.frame), 0);
                textView->currentSelectPosition = NSMakePoint(1, INT32_MAX); //location.y < 3 ? (count-1) : 0 ;
                
            } else if(i == startRow) {
                
                if(!isMultiple) {
                    
                    textView->startSelectPosition = startConverted;
                    textView->currentSelectPosition = [textView convertPoint:point fromView:nil];
                    
                    
                } else {
                    
                    if(!reversed) {
                        
                        textView->startSelectPosition = NSMakePoint(startConverted.x, startConverted.y);
                        textView->currentSelectPosition = NSMakePoint(1, INT32_MAX);
                        
                    } else {
                        
                        // its end :D
                        
                        textView->startSelectPosition = NSMakePoint(0, INT32_MAX);
                        textView->currentSelectPosition = currentConverted;
                        
                        
                    }
                    
                }
                
             } else if(i == endRow) {
                
                if(!reversed) {
                    textView->startSelectPosition = NSMakePoint(NSWidth(textView.frame), 0);
                    textView->currentSelectPosition = [textView convertPoint:point fromView:nil];
                    
                    
                } else {
                    
                    // its start lol, because reversed ;)
                    
                    textView->startSelectPosition = startConverted;
                    textView->currentSelectPosition = NSMakePoint(NSWidth(textView.frame), 0); 
                }
            }
            
            
            [textView setNeedsDisplay:YES];
            
            [SelectTextManager addRange:textView.selectRange forItem:item];
            
        }
        
    }
    

}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [SelectTextManager clear];
}


- (void)viewDidEndLiveResize {
    for(NSUInteger i = 0; i < self.viewController.messagesCount; i++) {
        MessageTableItem *item = (MessageTableItem *)[self itemByPosition:i];
        [item makeSizeByWidth:self.containerSize.width];
    }
    
    [self reloadData];
}



@end
