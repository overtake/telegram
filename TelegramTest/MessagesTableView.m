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






@interface MessagesTableView() <TMScrollViewDelegate>
@property (nonatomic) NSSize oldSize;
@property (nonatomic) NSSize oldFixedSize;
@property (nonatomic) NSSize oldOldSize;

@property (nonatomic) BOOL isLocked;
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
    NSLog(@"log");
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


-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    NSLog(@"test");
}


- (void)viewDidEndLiveResize {
    for(NSUInteger i = 0; i < self.viewController.messagesCount; i++) {
        MessageTableItem *item = (MessageTableItem *)[self itemByPosition:i];
        [item makeSizeByWidth:self.containerSize.width];
    }
    
    [self reloadData];
}




@end
