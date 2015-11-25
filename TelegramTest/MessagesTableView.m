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
#import "TGTimer.h"





@interface MessagesTableView() <TMScrollViewDelegate, SelectTextManagerDelegate>
@property (nonatomic) NSSize oldSize;
@property (nonatomic) NSSize oldFixedSize;
@property (nonatomic) NSSize oldOldSize;

@property (nonatomic) BOOL isLocked;


@property (nonatomic,strong) MessageTableItemText *firstSelectItem;
@property (nonatomic,strong) MessageTableItemText *currentSelectItem;

@property (nonatomic,strong) NSTrackingArea *trackingArea;
@property (nonatomic,assign) NSPoint startSelectPosition; // not converted

@property (nonatomic,strong) TGTimer *timer;

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
    [self reloadData];
}

- (NSObject *)itemByPosition:(NSUInteger)position {
    return [self.viewController objectAtIndex:position];
}

- (NSSize)containerSize {
    return NSMakeSize(NSWidth(self.containerView.frame) - 150, 0);
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
                
                if([item makeSizeByWidth:item.makeSize]) {
                    id view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
                  //  if([view isKindOfClass:[MessageTableCellTextView class]]) {
                    if(view)
                        [array addObject:view];
                  //  }
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
        [item makeSizeByWidth:item.makeSize];
    }
    
  //  [self reloadData];
    
    
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
        if([container isKindOfClass:[MessageTableCellContainerView class]])
            [container clearSelection];
        
    }];
}

-(NSUInteger)indexOfItem:(NSObject *)item {
    return [[self.viewController messageList] indexOfObject:item];
}


-(void)checkAndScroll:(NSPoint)point {
    
//    
//    NSPoint topCorner = NSMakePoint(0, roundf(NSHeight(self.scrollView.frame) - 70));
//    
//    
//    NSPoint botCorner = NSMakePoint(0, 70);
//    
//    int counter = 0;
//    
//    BOOL next = YES;
//    
//    if(point.y > topCorner.y) {
//        
//        counter = abs(point.y - topCorner.y - 20);
//        
//        [self.scrollView scrollToPoint:NSMakePoint(self.scrollView.documentOffset.x, self.scrollView.documentOffset.y - counter) animation:NO];
//        
//    } else if(point.y < botCorner.y) {
//        
//        counter = abs(point.y - botCorner.y - 20);
//        
//       [self.scrollView scrollToPoint:NSMakePoint(self.scrollView.documentOffset.x, self.scrollView.documentOffset.y + counter) animation:NO];
//    } else
//        next = NO;
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    _startSelectPosition = NSMakePoint(INT32_MIN, INT32_MIN);
    [super mouseUp:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    
    if(_startSelectPosition.x == INT32_MIN && _startSelectPosition.y == INT32_MIN)
        return;
    
    [SelectTextManager clear];
    [SelectTextManager becomeFirstResponder];
    
    NSPoint point = [theEvent locationInWindow]; // not converted
    
    NSPoint startTablePoint = [self convertPoint:point fromView:nil];
    
    if(startTablePoint.x < 0) {
        startTablePoint.x = 0;
    }
    if(startTablePoint.x > NSWidth(self.frame)) {
        startTablePoint.x = NSWidth(self.frame) - 1;
    }
    if(startTablePoint.y < 0) {
        startTablePoint.y = 0;
    }
    if(startTablePoint.y > NSHeight(self.frame)) {
        startTablePoint.y = NSHeight(self.frame) - 1;
    }
    
    
    [self checkAndScroll:[self.scrollView convertPoint:point fromView:nil]];

    
    NSUInteger row = [self rowAtPoint:startTablePoint];
    
    if(row == NSUIntegerMax && startTablePoint.y > 0 && NSHeight(self.frame) == NSHeight(self.scrollView.frame)) {
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
        
        
        MessageTableItem *item = self.viewController.messageList[i];
        
        if([item isKindOfClass:[MessageTableItemText class]]) {
            
            MessageTableItemText *textItem = (MessageTableItemText *)item;
            
            NSPoint startPoint;
            NSPoint endPoint;
            
            NSRect rect = [self rectOfRow:i];
            
            MessageTableCellTextView * view;
            
            @try {
                
                view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
            }
            @catch (NSException *exception) {
                
            }
            
            TGCTextView *textView = ((MessageTableCellTextView *)view).textView;
            
            NSPoint startConverted = NSMakePoint(_startSelectPosition.x - rect.origin.x - (item.isForwadedMessage ? item.containerOffsetForward : item.containerOffset), _startSelectPosition.y - rect.origin.y - NSMinY(view.containerView.frame));
            
            NSPoint currentConverted = NSMakePoint(startTablePoint.x - rect.origin.x - (item.isForwadedMessage ? item.containerOffsetForward : item.containerOffset), startTablePoint.y - rect.origin.y - NSMinY(view.containerView.frame));
            
            

            
            if(i > startRow && i < endRow) {
                
                startPoint = NSMakePoint(textItem.blockSize.width, 0);
                endPoint = NSMakePoint(1, INT32_MAX);
                
            } else if(i == startRow) {
                
                if(!isMultiple) {
                    
                    startPoint = startConverted;
                    endPoint = currentConverted;
                    
                    
                } else {
                    
                    if(!reversed) {
                        
                        startPoint = NSMakePoint(startConverted.x, startConverted.y);
                        endPoint = NSMakePoint(1, INT32_MAX);
                        
                    } else {
                        
                        // its end :D
                        
                        startPoint = NSMakePoint(0, INT32_MAX);
                        endPoint = currentConverted;
                        
                        
                    }
                    
                }
                
            } else if(i == endRow) {
                
                if(!reversed) {
                    startPoint = NSMakePoint(textItem.blockSize.width, 0);
                    endPoint = currentConverted;
                    
                    
                } else {
                    
                    startPoint = startConverted;
                    endPoint = NSMakePoint(textItem.blockSize.width, 0);
                }
            }
            
            NSRange selectRange = [textItem.textAttributed selectRange:textItem.blockSize startPoint:startPoint currentPoint:endPoint];
            
            
            [SelectTextManager addRange:selectRange forItem:item];
            
            
            [textView setSelectionRange:selectRange];
            
            
        }
        
        
    }
    

}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [SelectTextManager clear];
}


- (void)viewDidEndLiveResize {
    for(NSUInteger i = 0; i < self.viewController.messagesCount; i++) {
        MessageTableItem *item = (MessageTableItem *)[self itemByPosition:i];
        [item makeSizeByWidth:item.makeSize];
    }
    
    [self reloadData];
}



@end
